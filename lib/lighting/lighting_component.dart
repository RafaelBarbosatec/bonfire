import 'dart:ui' as ui;

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

  /// Adds a light that is not attached to a component.
  LightSource addLight(LightSource light);

  /// Removes a light previously added with [addLight].
  bool removeLight(LightSource light);
}

/// Layer component responsible for adding lighting to the game.
class LightingComponent extends GameComponent implements LightingInterface {
  final Paint _paintLighting = Paint();
  final Paint _paintLightingArc = Paint();

  final List<LightSource> _lightSources = [];

  ColorTween? _tween;
  bool _containColor = false;
  Rect? bounds;
  @override
  Color? color;

  LightingComponent({this.color});

  /// Lights added through [addLight].
  List<LightSource> get lightSources => List.unmodifiable(_lightSources);

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
  LightSource addLight(LightSource light) {
    _lightSources.add(light);
    return light;
  }

  @override
  bool removeLight(LightSource light) => _lightSources.remove(light);

  @override
  void renderTree(Canvas canvas) {
    final componentLights =
        _visibleLight.where(_isLightRenderable).toList(growable: false);
    final lightSources = _lightSources
        .where((light) => light.enabled && _isLightSourceVisible(light))
        .toList(growable: false);

    final hasAmbient = _containColor;

    final additive = <_PendingLight>[];
    final cutout = <_PendingLight>[];

    for (final light in componentLights) {
      final config = light.lighting.config!;
      final pending = _PendingLight(
        config: config,
        center: light.absoluteCenter + config.align,
        angle: light.lighting.angle,
      );
      if (config.mode == LightingMode.additive) {
        additive.add(pending);
      } else if (hasAmbient) {
        // A cutout light only makes sense when there is ambient darkness to
        // erase.
        cutout.add(pending);
      }
    }

    for (final light in lightSources) {
      final config = light.config;
      final pending = _PendingLight(
        config: config,
        center: light.position + config.align,
        angle: light.angle,
      );
      if (config.mode == LightingMode.additive) {
        additive.add(pending);
      } else if (hasAmbient) {
        cutout.add(pending);
      }
    }

    if (additive.isEmpty && !hasAmbient) {
      return;
    }

    // Additive lights are composited *below* the ambient darkness, so the
    // ambient color darkens them instead of the light being painted on top of
    // the night color.
    if (additive.isNotEmpty) {
      canvas.saveLayer(bounds, paint);
      canvas.save();
      _applyCameraTransform(canvas);

      for (final light in additive) {
        _renderLight(
          canvas,
          config: light.config,
          center: light.center,
          angle: light.angle,
          cutout: false,
        );
      }

      canvas.restore();
      canvas.restore();
    }

    if (hasAmbient) {
      canvas.saveLayer(bounds, paint);
      canvas.drawColor(color!, BlendMode.dstATop);
      canvas.save();
      _applyCameraTransform(canvas);

      for (final light in cutout) {
        _renderLight(
          canvas,
          config: light.config,
          center: light.center,
          angle: light.angle,
          cutout: true,
        );
      }

      canvas.restore();
      canvas.restore();
    }
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

  bool _isLightSourceVisible(LightSource light) {
    final camera = gameRef.camera;
    return camera.cameraRectWithSpacing
        .inflate(light.config.radius)
        .contains(light.position.toOffset());
  }

  @override
  void update(double dt) {
    _containColor = _containsColor();

    for (final light in _visibleLight) {
      if (_isLightRenderable(light)) {
        light.lighting.config!.update(dt);
      }
    }

    for (final light in _lightSources) {
      if (light.enabled) {
        light.config.update(dt);
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

  void _renderLight(
    Canvas canvas, {
    required LightingConfig config,
    required Vector2 center,
    required double angle,
    required bool cutout,
  }) {
    if (config.type is ArcLightingType) {
      _drawArc(
        canvas,
        config: config,
        center: center.toOffset(),
        angle: angle,
        cutout: cutout,
      );
    } else {
      _drawCircle(
        canvas,
        config: config,
        center: center.toOffset(),
        radius: config.radiusWithEffects,
        cutout: cutout,
      );
    }
  }

  void _drawArc(
    Canvas canvas, {
    required LightingConfig config,
    required Offset center,
    required double angle,
    required bool cutout,
  }) {
    final type = config.type as ArcLightingType;
    // `radius` is the actual reach of the light, the same unit used by circle
    // lights, so switching between `arc` and `circle` keeps the same coverage.
    final radius = config.radiusWithEffects;

    canvas.save();

    if (angle != 0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
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

    final area = Rect.fromCircle(radius: radius, center: center);

    if (cutout) {
      canvas.drawPath(
        path,
        _buildPaint(config, area, cutout: true, erase: true, arc: true),
      );
    }

    canvas.drawPath(
      path,
      _buildPaint(config, area, cutout: cutout, arc: true),
    );

    canvas.restore();
  }

  void _drawCircle(
    Canvas canvas, {
    required LightingConfig config,
    required Offset center,
    required double radius,
    required bool cutout,
  }) {
    final area = Rect.fromCircle(center: center, radius: radius);

    if (cutout) {
      canvas.drawCircle(
        center,
        radius,
        _buildPaint(config, area, cutout: true, erase: true),
      );
    }

    canvas.drawCircle(
      center,
      radius,
      _buildPaint(config, area, cutout: cutout),
    );
  }

  /// Builds the paint for a light.
  ///
  /// When [erase] is true the paint cuts the ambient darkness instead of
  /// tinting it. With a gradient [LightFalloff] the cut is proportional to the
  /// gradient alpha (`BlendMode.dstOut`), which produces a soft edge without
  /// the cost of `MaskFilter.blur`.
  Paint _buildPaint(
    LightingConfig config,
    Rect area, {
    required bool cutout,
    bool erase = false,
    bool arc = false,
  }) {
    final paint = arc ? _paintLightingArc : _paintLighting;
    final color = erase ? const Color(0xFFFFFFFF) : config.effectiveColor;
    final blendMode = erase
        ? null
        : cutout
            ? BlendMode.srcOver
            : config.additiveBlendMode;

    if (config.falloff == LightFalloff.blur) {
      paint
        ..shader = null
        ..color = color
        ..maskFilter = config.maskFilter
        ..blendMode = erase ? BlendMode.clear : blendMode!;
    } else {
      paint
        ..shader = _falloffShader(config, area, color)
        ..maskFilter = null
        ..blendMode = erase ? BlendMode.dstOut : blendMode!;
    }
    return paint;
  }

  ui.Shader _falloffShader(LightingConfig config, Rect area, Color color) {
    final inner = config.innerRadius.clamp(0.0, 1.0);

    // No falloff: the whole shape has full intensity.
    if (inner >= 1) {
      return ui.Gradient.radial(
        area.center,
        area.width / 2,
        [color, color],
        [0, 1],
      );
    }

    final transparent = color.withValues(alpha: 0);
    final colors = <Color>[];
    final stops = <double>[];

    if (inner > 0) {
      colors
        ..add(color)
        ..add(color);
      stops
        ..add(0)
        ..add(inner);
    } else {
      colors.add(color);
      stops.add(0);
    }

    if (config.falloff == LightFalloff.linear) {
      colors.add(transparent);
      stops.add(1);
    } else {
      const samples = 6;
      for (var i = 1; i <= samples; i++) {
        final t = i / samples;
        // 1 - smoothstep(t)
        final alpha = 1 - (t * t * (3 - 2 * t));
        colors.add(color.withValues(alpha: color.a * alpha));
        stops.add(inner + (1 - inner) * t);
      }
    }

    return ui.Gradient.radial(area.center, area.width / 2, colors, stops);
  }

  @override
  void onGameResize(Vector2 size) {
    bounds = gameRef.camera.viewport.virtualSize.toRect();
    super.onGameResize(size);
  }
}

/// A light resolved to world coordinates, ready to be rendered.
class _PendingLight {
  final LightingConfig config;
  final Vector2 center;
  final double angle;

  const _PendingLight({
    required this.config,
    required this.center,
    required this.angle,
  });
}
