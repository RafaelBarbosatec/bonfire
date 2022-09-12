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
    Vector2 size = gameRef.camera.canvasSize;
    canvas.saveLayer(Offset.zero & Size(size.x, size.y), paint);
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
  void update(double dt) {
    _containColor = _containsColor();
    if (!_containColor) return;
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
    Offset offset = light.center.toOffset() + config.align.toOffset();
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
      _paintFocusArc
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          config.blurSigma,
        ),
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
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          config.blurSigma,
        ),
    );

    canvas.restore();
  }

  void _drawCircle(Canvas canvas, Lighting light) {
    var config = light.lightingConfig!;
    Offset offset = light.center.toOffset() + config.align.toOffset();
    canvas.drawCircle(
      offset,
      config.radius *
          (config.withPulse
              ? (1 - config.valuePulse * config.pulseVariation)
              : 1),
      _paintFocus
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          config.blurSigma,
        ),
    );

    _paintLighting
      ..color = config.color
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        config.blurSigma,
      );
    canvas.drawCircle(
      offset,
      config.radius *
          (config.withPulse
              ? (1 - config.valuePulse * config.pulseVariation)
              : 1),
      _paintLighting,
    );
  }
}
