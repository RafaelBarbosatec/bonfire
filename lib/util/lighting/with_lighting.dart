import 'package:bonfire/util/lighting/lighting_config.dart';
import 'package:flutter/material.dart';

mixin WithLighting {
  LightingConfig lightingConfig;

  bool isVisible(Size sizeScreen) {
    if (lightingConfig == null ||
        sizeScreen == null ||
        lightingConfig?.gameComponent?.position == null) return false;

    Rect rectLight = Rect.fromLTWH(
      lightingConfig.gameComponent.position.left - lightingConfig.radius,
      lightingConfig.gameComponent.position.top - lightingConfig.radius,
      lightingConfig.radius * 2,
      lightingConfig.radius * 2,
    );

    return rectLight.top < (sizeScreen.height + rectLight.height) &&
        rectLight.top > (rectLight.height * -1) &&
        rectLight.left > (rectLight.width * -1) &&
        rectLight.left < (sizeScreen.width + rectLight.width);
  }
}
