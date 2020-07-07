import 'dart:ui';

import 'package:bonfire/util/game_component.dart';
import 'package:bonfire/util/lighting/lighting_config.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flutter/material.dart';

class LightingComponent extends GameComponent {
  Color color;
  Paint _paintFocus;
  Iterable<LightingConfig> _visibleLight = List();
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
      light.update(_dtUpdate);
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
        light.radius *
            (light.withPulse
                ? (1 - light.valuePulse * light.pulseVariation)
                : 1),
        _paintFocus
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            convertRadiusToSigma(light.blurBorder),
          ),
      );

      if (light.color != null) {
        final Paint paint = Paint()
          ..color = light.color
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            convertRadiusToSigma(light.blurBorder),
          );
        canvas.drawCircle(
          Offset(light.gameComponent.position.center.dx,
              light.gameComponent.position.center.dy),
          light.radius *
              (light.withPulse
                  ? (1 - light.valuePulse * light.pulseVariation)
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
