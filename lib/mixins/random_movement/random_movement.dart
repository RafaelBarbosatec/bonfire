import 'package:bonfire/bonfire.dart';

export 'random_movement_api.dart';

/// Mixin responsible for adding random movement to a component.
///
/// The component must have a [Movement] mixin.
///
/// Access all random movement functionality through the [randomMovement] API:
/// ```dart
/// class MyEnemy extends SimpleEnemy with Movement, WithRandomMovement {
///   @override
///   void update(double dt) {
///     super.update(dt);
///     randomMovement.update(dt, speed: 20, maxDistance: 64);
///   }
/// }
/// ```
mixin WithRandomMovement on Movement {
  late final RandomMovementApi randomMovement = RandomMovementApi(this);
}
