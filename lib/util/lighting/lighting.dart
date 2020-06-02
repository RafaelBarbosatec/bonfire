import 'dart:ui';

import 'package:bonfire/util/game_component.dart';
import 'package:flutter/material.dart';

class Lighting extends GameComponent {
  Color color;
  Paint _paintFocus;

  @override
  bool isHud() => true;

  Lighting({this.color = Colors.transparent}) {
    _paintFocus = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;
  }

  @override
  int priority() => 19;

  @override
  void render(Canvas canvas) {
    Size size = gameRef.size;
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(color, BlendMode.dstATop);
    gameRef.lightVisible().forEach((light) {
      canvas.save();
      canvas.translate(
        -gameRef.gameCamera.position.x,
        -gameRef.gameCamera.position.y,
      );
      canvas.drawCircle(
          Offset(light.gameComponent.position.center.dx,
              light.gameComponent.position.center.dy),
          light.radius *
              (light.withPulse
                  ? (1 - light.valuePulse * light.pulseVariation)
                  : 1),
          _paintFocus
            ..maskFilter = MaskFilter.blur(
                BlurStyle.normal, convertRadiusToSigma(light.blurBorder)));

      if (light.color != null) {
        final Paint paint = Paint()
          ..color = light.color
          ..maskFilter = MaskFilter.blur(
              BlurStyle.normal, convertRadiusToSigma(light.blurBorder));
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
    gameRef.lightVisible().forEach((element) => element.update(dt));
  }
}
