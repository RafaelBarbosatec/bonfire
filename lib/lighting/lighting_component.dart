import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

abstract class LightingInterface {
  Color? color;
  final List<Lighting> _visibleLight = [];
  List<Lighting> get visibleLights => _visibleLight;
  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  });

  bool isEnabled();

  void addVisibleLighting(Lighting lighting) {
    if (!_visibleLight.contains(lighting)) {
      _visibleLight.add(lighting);
    }
  }

  void removeVisibleLighting(Lighting lighting) {
    _visibleLight.remove(lighting);
  }
}

/// Layer component responsible for adding lighting to the game.
class LightingComponent extends GameComponent with LightingInterface {
  final Paint _paintFocus = Paint()..blendMode = BlendMode.clear;
  final Paint _paintLighting = Paint();
  final Paint _paintFocusArc = Paint()..blendMode = BlendMode.clear;
  final Paint _paintLightingArc = Paint();

  double _dtUpdate = 0.0;
  ColorTween? _tween;
  bool _containColor = false;
  Rect? bounds;

  @override
  PositionType get positionType => PositionType.viewport;

  LightingComponent({Color? color}) {
    this.color = color;
  }

  @override
  int get priority {
    return LayerPriority.getLightingPriority(gameRef.highestPriority);
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

  @override
  void renderTree(Canvas canvas) {
    if (!_containColor) return;
    canvas.saveLayer(bounds, paint);
    canvas.drawColor(color!, BlendMode.dstATop);
    for (var light in _visibleLight) {
      final config = light.lightingConfig;
      if (config == null || !light.lightingEnabled) continue;
      config.update(_dtUpdate);
      canvas.save();

      canvas.scale(gameRef.camera.zoom);
      canvas.translate(
        -(gameRef.camera.position.x),
        -(gameRef.camera.position.y),
      );

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
    var config = light.lightingConfig!;
    var type = config.type as ArcLightingType;
    Offset offset = (light.center + config.align).toOffset();
    final maskFilter = MaskFilter.blur(
      BlurStyle.normal,
      config.blurSigma,
    );
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
      _paintFocusArc..maskFilter = maskFilter,
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
        ..maskFilter = maskFilter,
    );

    canvas.restore();
  }

  void _drawCircle(Canvas canvas, Lighting light) {
    var config = light.lightingConfig!;
    Offset offset = (light.center + config.align).toOffset();
    final maskFilter = MaskFilter.blur(
      BlurStyle.normal,
      config.blurSigma,
    );
    canvas.drawCircle(
      offset,
      config.radius *
          (config.withPulse
              ? (1 - config.valuePulse * config.pulseVariation)
              : 1),
      _paintFocus..maskFilter = maskFilter,
    );

    _paintLighting
      ..color = config.color
      ..maskFilter = maskFilter;
    canvas.drawCircle(
      offset,
      config.radius *
          (config.withPulse
              ? (1 - config.valuePulse * config.pulseVariation)
              : 1),
      _paintLighting,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    bounds = Rect.fromLTWH(left, top, size.x, size.y);
    super.onGameResize(size);
  }
}
