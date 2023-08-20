import 'package:bonfire/bonfire.dart';

// Mixin responsable to give the bounce behavior. (experimental)
mixin BouncingObject on BlockMovementCollision {
  double bouncingReflectFactor = 1.0;
  Vector2? currentCenter;

  bool onBouncingCollision(PositionComponent other) {
    return other is! Sensor;
  }

  @override
  void onBlockedMovement(
    PositionComponent other,
    Direction? direction,
    Vector2 lastDisplacement,
  ) {
    if (onBouncingCollision(other) && !velocity.isZero()) {
      if (direction == Direction.left || direction == Direction.right) {
        velocity.x = velocity.x * -bouncingReflectFactor;
      } else if (direction == Direction.up || direction == Direction.down) {
        velocity.y = velocity.y * -bouncingReflectFactor;
      } else {
        stopMove();
      }
    }
  }
}
