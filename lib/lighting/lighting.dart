import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/lighting/lighting_api.dart';

export 'lighting_api.dart';

/// Mixin used to configure lighting in your component.
///
/// Access all lighting functionality through the [lighting] API.
mixin WithLighting on GameComponent {
  late final LightingApi lighting = LightingApi(this);

  @override
  void update(double dt) {
    lighting.update(dt);
    super.update(dt);
  }

  @override
  bool get isVisible {
    return hasGameRef ? gameRef.camera.canSeeWithMargin(this) : false;
  }
}
