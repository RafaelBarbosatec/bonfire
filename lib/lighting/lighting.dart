import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/util/camera/camera.dart';
import 'package:flutter/material.dart';

mixin Lighting on GameComponent {
  LightingConfig _lightingConfig;

  setupLighting(LightingConfig config) {
    _lightingConfig = config;
  }

  LightingConfig get config => _lightingConfig;

  bool isVisible(Camera camera) {
    if (_lightingConfig == null ||
        camera == null ||
        this?.position == null ||
        camera.gameRef.size == null) return false;

    Rect rectLight = Rect.fromLTWH(
      this.position.rect.center.dx - (config.radius + config.blurBorder / 2),
      this.position.rect.center.dy - (config.radius + config.blurBorder / 2),
      (config.radius * 2) + config.blurBorder,
      (config.radius * 2) + config.blurBorder,
    );

    return camera.isRectOnCamera(rectLight) ?? false;
  }
}
