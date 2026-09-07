import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/mixins/follower/follower_api.dart';

export 'follower_api.dart';

/// Mixin that makes the component follow a target [GameComponent].
///
/// If target is null, nothing will happen until one is set.
///
/// Access all follow functionality through the [follower] API:
/// ```dart
/// class MyFollower extends GameComponent with WithFollower {
///   @override
///   void onMount() {
///     super.onMount();
///     follower.setup(target: player, offset: Vector2(10, 10));
///   }
/// }
/// ```
mixin WithFollower on GameComponent {
  late final FollowerApi follower = FollowerApi(this);

  @override
  void update(double dt) {
    follower.update(dt);
    super.update(dt);
  }

  @override
  int get priority => follower.priority;
}
