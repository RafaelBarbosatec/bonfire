import 'package:bonfire/bonfire.dart';

/// API used to configure lighting in a component.
class LightingApi {
  final GameComponent _comp;

  LightingConfig? _config;

  /// Used to define rotation angle.
  double angle = 0.0;

  /// Used to enable and disable light.
  bool enabled = true;

  LightingApi(this._comp);

  /// Current lighting configuration.
  LightingConfig? get config => _config;

  /// Sets the lighting configuration.
  void setup(LightingConfig? config) => _config = config;

  double _calculateAngle() {
    final config = _config;
    if (config != null && config.type is ArcLightingType) {
      final type = config.type as ArcLightingType;
      if (type.isCenter) {
        return _comp.angle - (type.endRadAngle / 2);
      } else {
        return _comp.angle - type.endRadAngle;
      }
    }
    return 0.0;
  }

  /// Updates lighting state. Should be called by the component's [update].
  void update(double dt) {
    if (_config?.useComponentAngle == true) {
      angle = _calculateAngle();
    }
  }
}
