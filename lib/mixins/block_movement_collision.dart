import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding collision
mixin BlockMovementCollision on GameComponent {
  void onStopMovement(GameComponent other) {}

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (this is Movement) {
      Movement comp = this as Movement;
      position += comp.lastDisplacement * -1;
      onStopMovement(other as GameComponent);
      comp.setZeroVelocity();
    }
    super.onCollision(intersectionPoints, other);
  }

  bool isCollision({Vector2? displacement}) {
    return false;
  }
}
