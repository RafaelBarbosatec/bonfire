// ignore_for_file: unnecessary_this

import 'package:bonfire/bonfire.dart';

/// Mixin used to configure lighting in your component
mixin Lighting on GameComponent {
  LightingConfig? _lightingConfig;

  /// Used to define rotation angle
  double lightingAngle = 0.0;

  /// Used to enable and disable light
  bool lightingEnabled = true;

  /// Used to set configuration
  void setupLighting(LightingConfig? config) => _lightingConfig = config;

  LightingConfig? get lightingConfig => _lightingConfig;

  double _lightingAngle() {
    if (_lightingConfig != null && _lightingConfig?.type is ArcLightingType) {
      var type = _lightingConfig?.type as ArcLightingType;
      if (type.isCenter) {
        return this.angle - (type.endRadAngle / 2);
      } else {
        return this.angle - type.endRadAngle;
      }
    }
    return 0.0;
  }

  @override
  void update(double dt) {
    if (_lightingConfig?.useComponentAngle == true) {
      lightingAngle = _lightingAngle();
    }
    super.update(dt);
  }

  @override
  // ignore: must_call_super
  bool isVisibleInCamera() {
    return hasGameRef ? gameRef.camera.canSeeWithMargin(this) : false;
  }
}
