import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

abstract class LightingInterface {
  Color? color;
  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  });
}

/// Layer component responsible for adding lighting to the game.
class LightingComponent extends GameComponent implements LightingInterface {
  Color? color;
  Paint _paintFocus = Paint()..blendMode = BlendMode.clear;
  Paint _paintLighting = Paint();
  Paint _paintFocusArc = Paint()..blendMode = BlendMode.clear;
  Paint _paintLightingArc = Paint();
  Iterable<Lighting> _visibleLight = [];
  double _dtUpdate = 0.0;
  ColorTween? _tween;
  bool _containColor = false;

  @override
  PositionType get positionType => PositionType.viewport;

  LightingComponent({this.color});

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
  void render(Canvas canvas) {
    super.render(canvas);
    if (!_containColor) return;
    Vector2 size = gameRef.camera.canvasSize;
    canvas.saveLayer(Offset.zero & Size(size.x, size.y), Paint());
    canvas.drawColor(color!, BlendMode.dstATop);
    _visibleLight.forEach((light) {
      final config = light.lightingConfig;
      if (config == null || !light.lightingEnabled) return;
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
    });
    canvas.restore();
  }

  @override
  // ignore: must_call_super
  void update(double dt) {
    _containColor = _containsColor();
    if (!_containColor) return;
    _dtUpdate = dt;
    _visibleLight = gameRef.visibleLighting();
  }

  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  }) {
    _tween = ColorTween(
      begin: this.color ?? Color(0x00000000),
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
    return color != null && color != Color(0x00000000);
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
