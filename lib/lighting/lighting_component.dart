import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

abstract class LightingInterface {
  Color? color;
  void animateToColor(
    Color color, {
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

  double _dtUpdate = 0.0;
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

  Iterable<Lighting> get _visibleLight {
    return gameRef.visibles<Lighting>();
  }

  @override
  void renderTree(Canvas canvas) {
    if (!_containColor) {
      return;
    }
    canvas.saveLayer(bounds, paint);
    canvas.drawColor(color!, BlendMode.dstATop);
    for (final light in _visibleLight) {
      final config = light.lightingConfig;
      if (config == null || !light.lightingEnabled) {
        continue;
      }
      config.update(_dtUpdate);
      canvas.save();

      canvas.scale(gameRef.camera.zoom);
      final tl = gameRef.camera.topleft;
      canvas.translate(-tl.x, -tl.y);

      if (config.type is CircleLightingType) {
        _drawCircle(canvas, light);
      }

      if (config.type is ArcLightingType) {
        _drawArc(canvas, light);
      }
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  // ignore: must_call_super
  void update(double dt) {
    _containColor = _containsColor();
    _dtUpdate = dt;
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

    generateValues(
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

  bool _containsColor() {
    return color != null && color != const Color(0x00000000);
  }

  void _drawArc(Canvas canvas, Lighting light) {
    final config = light.lightingConfig!;
    final type = config.type as ArcLightingType;
    final offset = (light.absoluteCenter + config.align).toOffset();

    canvas.save();

    canvas.translate(light.center.x, light.center.y);
    canvas.rotate(light.lightingAngle);
    canvas.translate(-light.center.x, -light.center.y);

    canvas.drawPath(
      Path()
        ..moveTo(offset.dx, offset.dy)
        ..arcTo(
          Rect.fromCircle(
            radius: config.radius * 2,
            center: offset,
          ),
          type.startRadAngle,
          type.endRadAngle,
          false,
        )
        ..close(),
      _paintFocusArc..maskFilter = config.maskFilter,
    );

    canvas.drawPath(
      Path()
        ..moveTo(offset.dx, offset.dy)
        ..arcTo(
          Rect.fromCircle(
            radius: light.lightingConfig!.radius * 2,
            center: offset,
          ),
          type.startRadAngle,
          type.endRadAngle,
          false,
        )
        ..close(),
      _paintLightingArc
        ..color = config.color
        ..maskFilter = config.maskFilter,
    );

    canvas.restore();
  }

  void _drawCircle(Canvas canvas, Lighting light) {
    final config = light.lightingConfig!;
    final offset = (light.absoluteCenter + config.align).toOffset();

    canvas.drawCircle(
      offset,
      config.radius * (1 - config.valuePulse),
      _paintFocus..maskFilter = config.maskFilter,
    );

    _paintLighting
      ..color = config.color
      ..maskFilter = config.maskFilter;

    canvas.drawCircle(
      offset,
      config.radius * (config.withPulse ? (1 - config.valuePulse) : 1),
      _paintLighting,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    bounds = gameRef.camera.viewport.virtualSize.toRect();
    super.onGameResize(size);
  }
}
