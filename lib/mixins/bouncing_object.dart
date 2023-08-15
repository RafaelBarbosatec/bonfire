import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision_util.dart';

// Mixin responsable to give the bounce behavior. (experimental)
mixin BouncingObject on Movement {
  final _collisionUtil = CollisionUtil();
  double bouncingReflectFactor = 1.0;
  Vector2? currentCenter;

  bool onBouncingCollision(PositionComponent other) {
    return other is! Sensor;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!onBouncingCollision(other)) {
      return;
    }

    if (other is Movement) {
      velocity -= other.velocity;
    }

    var rect = toAbsoluteRect();
    var midPoint = intersectionPoints.reduce(
      (value, element) => value + element,
    );
    midPoint /= intersectionPoints.length.toDouble();
    midPoint.lerp(rect.center.toVector2(), 0.2);
    Direction? directionCollision = _collisionUtil.getDirectionCollision(
      rect,
      midPoint,
    );

    if (directionCollision == Direction.left ||
        directionCollision == Direction.right) {
      velocity.x = velocity.x * -bouncingReflectFactor;
    } else if (directionCollision == Direction.up ||
        directionCollision == Direction.down) {
      velocity.y = velocity.y * -bouncingReflectFactor;
    } else {
      stopMove();
    }
  }
}
