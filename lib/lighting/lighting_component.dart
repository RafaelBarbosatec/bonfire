import 'package:bonfire/bonfire.dart';
import 'package:flame/extensions.dart' show CanvasExtension;
import 'package:flutter/widgets.dart';

abstract class LightingInterface {
  Color? color;
  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  });

  /// Animates the ambient color from fully transparent to [color].
  void fadeIn(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  });

  /// Animates the ambient color to fully transparent.
  void fadeOut({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  });

  bool isEnabled();
}

/// Layer component responsible for adding lighting to the game.
class LightingComponent extends GameComponent implements LightingInterface {
  final Paint _paintFocus = Paint()..blendMode = BlendMode.clear;
  final Paint _paintLighting = Paint();
  final Paint _paintFocusArc = Paint()..blendMode = BlendMode.clear;
  final Paint _paintLightingArc = Paint();

  ColorTween? _tween;
  bool _containColor = false;
  Rect? bounds;
  @override
  Color? color;

  LightingComponent({this.color});

  @override
  int get priority {
    return LayerPriority.getHudLightingPriority();
  }

  Path getWheelPath(double wheelSize, double fromRadius, double toRadius) {
    return Path()
      ..moveTo(wheelSize, wheelSize)
      ..arcTo(
        Rect.fromCircle(
          radius: wheelSize,
          center: Offset(wheelSize, wheelSize),
        ),
        fromRadius,
        toRadius,
        false,
      )
      ..close();
  }

  Iterable<WithLighting> get _visibleLight {
    return gameRef.visibles<WithLighting>();
  }

  @override
  void renderTree(Canvas canvas) {
    final lights = _visibleLight.where(_isLightRenderable).toList(
          growable: false,
        );

    final hasAmbient = _containColor;
    final hasAdditive = lights.any(
      (light) => light.lighting.config!.mode == LightingMode.additive,
    );

    if (!hasAmbient && !hasAdditive) {
      return;
    }

    canvas.saveLayer(bounds, paint);

    if (hasAmbient) {
      canvas.drawColor(color!, BlendMode.dstATop);
    }

    for (final light in lights) {
      final config = light.lighting.config!;
      final drawCutout = config.mode == LightingMode.cutout;

      // A cutout light only makes sense when there is ambient darkness to
      // erase. Additive lights are drawn even on fully lit scenes.
      if (drawCutout && !hasAmbient) {
        continue;
      }

      canvas.save();
      _applyCameraTransform(canvas);

      if (config.type is CircleLightingType) {
        _drawCircle(canvas, light, cutout: drawCutout);
      } else if (config.type is ArcLightingType) {
        _drawArc(canvas, light, cutout: drawCutout);
      }

      canvas.restore();
    }

    canvas.restore();
  }

  /// Applies the same transform the camera uses to render the world.
  ///
  /// Using the viewfinder transform (instead of manually translating by the
  /// camera top-left) keeps lights aligned when the camera is rotated or when
  /// a custom anchor is used.
  void _applyCameraTransform(Canvas canvas) {
    canvas.transform2D(gameRef.camera.viewfinder.transform);
  }

  bool _isLightRenderable(WithLighting light) {
    final config = light.lighting.config;
    return config != null && light.lighting.enabled;
  }

  @override
  void update(double dt) {
    _containColor = _containsColor();

    for (final light in _visibleLight) {
      if (_isLightRenderable(light)) {
        light.lighting.config!.update(dt);
      }
    }

    super.update(dt);
  }

  @override
  bool isEnabled() => _containColor;

  @override
  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  }) {
    _tween = ColorTween(
      begin: this.color ?? const Color(0x00000000),
      end: color,
    );

    util.generateValues(
      duration,
      onChange: (value) {
        this.color = _tween?.transform(value);
      },
      onFinish: () {
        this.color = color;
      },
      curve: curve,
    );
  }

  @override
  void fadeIn(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  }) {
    this.color = color.withValues(alpha: 0);
    animateToColor(color, duration: duration, curve: curve);
  }

  @override
  void fadeOut({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  }) {
    final current = color;
    if (current == null) {
      return;
    }
    animateToColor(
      current.withValues(alpha: 0),
      duration: duration,
      curve: curve,
    );
  }

  bool _containsColor() {
    return color != null && color!.a > 0;
  }

  void _drawArc(Canvas canvas, WithLighting light, {required bool cutout}) {
    final config = light.lighting.config!;
    final type = config.type as ArcLightingType;
    final center = (light.absoluteCenter + config.align).toOffset();
    // Kept as `radius * 2` to preserve the historical arc rendering: changing
    // it would alter every existing arc light. It can be revisited separately.
    final radius = config.radius * 2;

    canvas.save();

    if (light.lighting.angle != 0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(light.lighting.angle);
      canvas.translate(-center.dx, -center.dy);
    }

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(radius: radius, center: center),
        type.startRadAngle,
        type.endRadAngle,
        false,
      )
      ..close();

    if (cutout) {
      canvas.drawPath(
        path,
        _paintFocusArc..maskFilter = config.maskFilter,
      );
    }

    canvas.drawPath(
      path,
      _paintLightingArc
        ..color = config.color
        ..maskFilter = config.maskFilter
        ..blendMode = cutout ? BlendMode.srcOver : BlendMode.plus,
    );

    canvas.restore();
  }

  void _drawCircle(Canvas canvas, WithLighting light, {required bool cutout}) {
    final config = light.lighting.config!;
    final offset = (light.absoluteCenter + config.align).toOffset();
    final radius = config.radius * (1 - config.valuePulse);

    if (cutout) {
      canvas.drawCircle(
        offset,
        radius,
        _paintFocus..maskFilter = config.maskFilter,
      );
    }

    _paintLighting
      ..color = config.color
      ..maskFilter = config.maskFilter
      ..blendMode = cutout ? BlendMode.srcOver : BlendMode.plus;

    canvas.drawCircle(offset, radius, _paintLighting);
  }

  @override
  void onGameResize(Vector2 size) {
    bounds = gameRef.camera.viewport.virtualSize.toRect();
    super.onGameResize(size);
  }
}
