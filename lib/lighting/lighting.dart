import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/camera/camera.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:flutter/material.dart';

/// Mixin used to configure lighting in your component
mixin Lighting on GameComponent {
  LightingConfig? _lightingConfig;

  /// Used to set configuration
  setupLighting(LightingConfig? config) {
    if (config != null) {
      _lightingConfig = config;
    }
  }

  LightingConfig? get lightingConfig => _lightingConfig;

  bool isVisible(Camera camera) {
    if (lightingConfig == null) return false;

    Rect rectLight = Rect.fromLTWH(
      this.position.rect.center.dx -
          (lightingConfig!.radius + lightingConfig!.blurBorder / 2),
      this.position.rect.center.dy -
          (lightingConfig!.radius + lightingConfig!.blurBorder / 2),
      (lightingConfig!.radius * 2) + lightingConfig!.blurBorder,
      (lightingConfig!.radius * 2) + lightingConfig!.blurBorder,
    );

    return camera.isRectOnCamera(rectLight);
  }
}
