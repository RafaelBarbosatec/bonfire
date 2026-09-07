import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/mixins/life/life_api.dart';

export 'life_api.dart';

/// Mixin that adds life/health management to a game component.
///
/// Access all life functionality through the [life] API object:
/// ```dart
/// class MyEnemy extends SimpleEnemy {
///   @override
///   void onMount() {
///     super.onMount();
///     life.initial(200);
///     life.onDieListener(_onDie);
///     life.onRemoveLifeListener(_onDamage);
///   }
/// }
/// ```
mixin WithLife on GameComponent {
  late final LifeApi life = LifeApi(() => isRemoving);

  /// Shortcut getter for [LifeApi.isDead].
  bool get isDead => life.isDead;

  /// Returns the rect used to receive damage (component's collision rect).
  Rect rectAttackable() => rectCollision;

  @override
  void onRemove() {
    life.dispose();
    super.onRemove();
  }
}
