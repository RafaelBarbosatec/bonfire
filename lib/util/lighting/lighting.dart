import 'dart:ui';

import 'package:bonfire/util/game_component.dart';
import 'package:bonfire/util/lighting/lighting_config.dart';
import 'package:bonfire/util/lighting/with_lighting.dart';
import 'package:flutter/material.dart';

class Lighting extends GameComponent {
  Color color;
  Paint _paintFocus;
  Iterable<LightingConfig> _lightToRender = List();

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
    _lightToRender.forEach((light) {
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
    });
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  @override
  void update(double dt) {
    _lightToRender = gameRef.components
        .where((element) =>
            element is WithLighting &&
            (element as WithLighting).lightingConfig != null &&
            _lightingIsVisible((element as WithLighting).lightingConfig))
        .map((e) => (e as WithLighting).lightingConfig..update(dt));
  }

  bool _lightingIsVisible(LightingConfig lightingConfig) {
    if (gameRef == null ||
        gameRef.size == null ||
        lightingConfig.gameComponent.position == null) return false;

    Rect rectLight = Rect.fromLTWH(
      lightingConfig.gameComponent.position.left - lightingConfig.radius,
      lightingConfig.gameComponent.position.top - lightingConfig.radius,
      lightingConfig.radius * 2,
      lightingConfig.radius * 2,
    );

    return rectLight.top < (gameRef.size.height + rectLight.height) &&
        rectLight.top > (rectLight.height * -1) &&
        rectLight.left > (rectLight.width * -1) &&
        rectLight.left < (gameRef.size.width + rectLight.width);
  }
}
