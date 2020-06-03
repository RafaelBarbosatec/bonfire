import 'package:bonfire/util/camera.dart';
import 'package:bonfire/util/lighting/lighting_config.dart';
import 'package:flutter/material.dart';

mixin WithLighting {
  LightingConfig lightingConfig;

  bool isVisible(Camera camera) {
    if (lightingConfig == null ||
        camera == null ||
        lightingConfig?.gameComponent?.position == null) return false;

    Rect rectLight = Rect.fromLTWH(
      lightingConfig.gameComponent.position.left - lightingConfig.radius,
      lightingConfig.gameComponent.position.top - lightingConfig.radius,
      lightingConfig.radius * 2,
      lightingConfig.radius * 2,
    );

    return camera.cameraRect.overlaps(rectLight) ?? false;
  }
}
