import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/util/camera/camera.dart';
import 'package:flutter/material.dart';

mixin Lighting {
  LightingConfig lightingConfig;

  bool isVisible(Camera camera) {
    if (lightingConfig == null ||
        camera == null ||
        gameComponent?.position == null ||
        camera.gameRef.size == null) return false;

    Rect rectLight = Rect.fromLTWH(
      gameComponent.position.left - (lightingConfig.radius + 10),
      gameComponent.position.top - (lightingConfig.radius + 10),
      (lightingConfig.radius * 2) + 20,
      (lightingConfig.radius * 2) + 20,
    );

    return camera.cameraRect.overlaps(rectLight) ?? false;
  }

  GameComponent get gameComponent => (this as GameComponent);
}
