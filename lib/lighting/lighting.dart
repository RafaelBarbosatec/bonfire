import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/util/camera/camera.dart';
import 'package:flutter/material.dart';

mixin Lighting on GameComponent {
  LightingConfig lightingConfig;

  bool isVisible(Camera camera) {
    if (lightingConfig == null ||
        camera == null ||
        this?.position == null ||
        camera.gameRef.size == null) return false;

    Rect rectLight = Rect.fromLTWH(
      this.position.rect.center.dx -
          (lightingConfig.radius + lightingConfig.blurBorder / 2),
      this.position.rect.center.dy -
          (lightingConfig.radius + lightingConfig.blurBorder / 2),
      (lightingConfig.radius * 2) + lightingConfig.blurBorder,
      (lightingConfig.radius * 2) + lightingConfig.blurBorder,
    );

    return camera.isRectOnCamera(rectLight) ?? false;
  }
}
