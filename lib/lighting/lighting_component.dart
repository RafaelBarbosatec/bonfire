import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/lighting/lighting.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flutter/material.dart';

/// Layer component responsible for adding lighting to the game.
class LightingComponent extends GameComponent {
  Color? color;
  late Paint _paintFocus;
  Iterable<Lighting> _visibleLight = [];
  double _dtUpdate = 0.0;
  ColorTween? _tween;

  @override
  bool get isHud => true;

  LightingComponent({this.color}) {
    _paintFocus = Paint()..blendMode = BlendMode.clear;
  }

  @override
  int get priority =>
      LayerPriority.getLightingPriority(gameRef.highestPriority);

  @override
  void render(Canvas canvas) {
    if (color == null) return;
    Vector2 size = gameRef.size;
    canvas.saveLayer(Offset.zero & Size(size.x, size.y), Paint());
    canvas.drawColor(color!, BlendMode.dstATop);
    _visibleLight.forEach((light) {
      final config = light.lightingConfig;
      if (config == null) return;
      final sigma = _convertRadiusToSigma(config.blurBorder);
      config.update(_dtUpdate);
      canvas.save();

      canvas.translate(size.x / 2, size.y / 2);
      canvas.scale(gameRef.camera.config.zoom);
      canvas.translate(
        -(gameRef.camera.position.dx),
        -(gameRef.camera.position.dy),
      );

      canvas.drawCircle(
        Offset(
          light.position.center.dx,
          light.position.center.dy,
        ),
        config.radius *
            (config.withPulse
                ? (1 - config.valuePulse * config.pulseVariation)
                : 1),
        _paintFocus
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            sigma,
          ),
      );

      final Paint paint = Paint()
        ..color = config.color
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          sigma,
        );
      canvas.drawCircle(
        Offset(
          light.position.center.dx,
          light.position.center.dy,
        ),
        config.radius *
            (config.withPulse
                ? (1 - config.valuePulse * config.pulseVariation)
                : 1),
        paint,
      );

      canvas.restore();
    });
    canvas.restore();
  }

  static double _convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  @override
  void update(double dt) {
    if (color == null) return;
    _dtUpdate = dt;
    _visibleLight = gameRef.lightVisible();
  }

  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  }) {
    _tween = ColorTween(begin: this.color ?? Colors.transparent, end: color);

    gameRef.getValueGenerator(
      duration,
      onChange: (value) {
        this.color = _tween?.transform(value);
      },
      onFinish: () {
        this.color = color;
      },
      curve: curve,
    ).start();
  }
}
