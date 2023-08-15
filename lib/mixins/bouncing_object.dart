import 'package:bonfire/bonfire.dart';

// Mixin responsable to give the bounce behavior. (experimental)
mixin BouncingObject on Movement {
  double bouncingObjectFactor = 1.0;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (!velocity.isZero()) {
      if (other is Movement) {
        velocity -= other.velocity;
      }
      RaycastResult<ShapeHitbox>? resust;
      try {
        resust = gameRef.raycast(
          Ray2(origin: absoluteCenter, direction: velocity.normalized()),
        );
        // ignore: empty_catches
      } catch (e) {}

      if (resust?.reflectionRay?.direction != null) {
        final d = resust!.reflectionRay!.direction;
        if (d.x > 0) {
          velocity.x = velocity.x.abs();
        } else if (d.x < 0) {
          velocity.x = -velocity.x.abs();
        }

        if (d.y > 0) {
          velocity.y = velocity.y.abs();
        } else if (d.y < 0) {
          velocity.y = -velocity.y.abs();
        }
      }
    }
  }
}
