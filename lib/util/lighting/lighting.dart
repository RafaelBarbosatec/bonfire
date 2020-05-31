import 'dart:ui';

import 'package:bonfire/util/game_component.dart';
import 'package:bonfire/util/interval_tick.dart';
import 'package:bonfire/util/lighting/lighting_config.dart';
import 'package:bonfire/util/lighting/with_lighting.dart';
import 'package:flutter/material.dart';

class Lighting extends GameComponent {
  Color color;
  Paint _paintFocus;
  Iterable<LightingConfig> _lightToRender = List();
  IntervalTick _intervalTick;

  @override
  bool isHud() => true;

  Lighting({this.color = Colors.transparent}) {
    _paintFocus = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;
    _intervalTick = IntervalTick(10, updateListLight);
  }

  @override
  int priority() => 19;

  @override
  void render(Canvas canvas) {
    Size size = gameRef.size;
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(color, BlendMode.dstATop);
    _lightToRender.forEach((light) {
      canvas.save();
      canvas.translate(
          -gameRef.gameCamera.position.x, -gameRef.gameCamera.position.y);
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
      canvas.restore();
    });
    canvas.restore();
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  @override
  void update(double dt) {
    _intervalTick.update(dt);
    _lightToRender.forEach((element) => element.update(dt));
  }

  bool _lightingIsVisible(LightingConfig lightingConfig) {
    if (gameRef?.size == null || lightingConfig.gameComponent.position == null)
      return false;

    Rect rectLight = Rect.fromLTWH(
      lightingConfig.gameComponent.position.left - lightingConfig.radius,
      lightingConfig.gameComponent.position.top - lightingConfig.radius,
      lightingConfig.radius * 2,
      lightingConfig.radius * 2,
    );

    return gameRef.gameCamera.cameraRect.overlaps(rectLight);
  }

  void updateListLight() {
    _lightToRender = gameRef.components
        .where((element) =>
            element is WithLighting &&
            (element as WithLighting).lightingConfig != null &&
            _lightingIsVisible((element as WithLighting).lightingConfig))
        .map((e) => (e as WithLighting).lightingConfig);
  }
}
