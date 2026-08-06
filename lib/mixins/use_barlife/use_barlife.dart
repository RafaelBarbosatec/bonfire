import 'package:bonfire/bonfire.dart';

export 'life_bar_api.dart';

/// Mixin used to add a life bar to an attackable component.
///
/// The component must have a [WithLife] mixin.
///
/// Access all life bar functionality through the [lifeBar] API.
mixin WithLifeBar on WithLife {
  late final LifeBarApi lifeBar = LifeBarApi(this);

  @override
  void onMount() {
    lifeBar.mount();
    super.onMount();
  }

  @override
  void onRemove() {
    lifeBar.dispose();
    super.onRemove();
  }
}
