import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding collision
mixin BlockMovementCollision on Movement {
  bool onBlockMovement(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    return true;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    bool stopOtherMovement = true;
    bool stopMovement = other is GameComponent
        ? onBlockMovement(intersectionPoints, other)
        : true;
    if (stopMovement && other is BlockMovementCollision) {
      stopOtherMovement = other.onBlockMovement(intersectionPoints, this);
    }
    if (stopMovement && stopOtherMovement && other is! Sensor) {
      position += lastDisplacement * -1;
      stopFromCollision();
    }

    super.onCollision(intersectionPoints, other);
  }
}
