import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/lighting/lighting.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flutter/material.dart';

class LightingComponent extends GameComponent {
  Color color;
  Paint _paintFocus;
  Iterable<Lighting> _visibleLight = List();
  double _dtUpdate = 0.0;

  @override
  bool isHud() => true;

  LightingComponent({this.color = Colors.transparent}) {
    _paintFocus = Paint()..blendMode = BlendMode.clear;
  }

  @override
  int priority() => PriorityLayer.LIGHTING;

  @override
  void render(Canvas canvas) {
    Size size = gameRef.size;
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(color, BlendMode.dstATop);
    _visibleLight.forEach((light) {
      final config = light.lightingConfig;
      config.update(_dtUpdate);
      canvas.save();

      canvas.translate(size.width / 2, size.height / 2);
      canvas.scale(gameRef.gameCamera.zoom);
      canvas.translate(
        -gameRef.gameCamera.position.x,
        -gameRef.gameCamera.position.y,
      );

      canvas.drawCircle(
        Offset(
          light.gameComponent.position.center.dx,
          light.gameComponent.position.center.dy,
        ),
        light.lightingConfig.radius *
            (light.lightingConfig.withPulse
                ? (1 - config.valuePulse * config.pulseVariation)
                : 1),
        _paintFocus
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            convertRadiusToSigma(config.blurBorder),
          ),
      );

      if (config.color != null) {
        final Paint paint = Paint()
          ..color = config.color
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            convertRadiusToSigma(config.blurBorder),
          );
        canvas.drawCircle(
          Offset(light.gameComponent.position.center.dx,
              light.gameComponent.position.center.dy),
          config.radius *
              (config.withPulse
                  ? (1 - config.valuePulse * config.pulseVariation)
                  : 1),
          paint,
        );
      }
      canvas.restore();
    });
    canvas.restore();
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  @override
  void update(double dt) {
    _dtUpdate = dt;
    _visibleLight = gameRef.lightVisible();
  }
}
