import 'package:bonfire/bonfire.dart';

// Mixin responsable to give the bounce behavior.
mixin BouncingObject on Movement {
  double bouncingObjectFactor = 1.0;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (!velocity.isZero()) {
      final collisionPoint = intersectionPoints.first;
      if (other is Movement) {
        velocity -= other.velocity;
      }

      final c = absoluteCenter;

      // Right Side Collision
      if (collisionPoint.x > c.x) {
        velocity.x = -velocity.x * bouncingObjectFactor;
        velocity.y = velocity.y * bouncingObjectFactor;
      }
      // Lef Side Collision
      if (collisionPoint.x < c.x) {
        velocity.x = -velocity.x * bouncingObjectFactor;
        velocity.y = velocity.y * bouncingObjectFactor;
      }
      // Top Side Collision
      if (collisionPoint.y < c.y) {
        velocity.x = velocity.x * bouncingObjectFactor;
        velocity.y = -velocity.y * bouncingObjectFactor;
      }
      // // Bottom Side Collision
      if (collisionPoint.y > c.y) {
        velocity.x = velocity.x * bouncingObjectFactor;
        velocity.y = -velocity.y * bouncingObjectFactor;
      }
    }
  }
}
