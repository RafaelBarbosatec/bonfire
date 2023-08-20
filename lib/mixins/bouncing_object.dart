import 'package:bonfire/bonfire.dart';

// Mixin responsable to give the bounce behavior. (experimental)
mixin BouncingObject on BlockMovementCollision {
  double _bouncingReflectFactor = 1.0;
  bool _bouncingObjectEnabled = true;

  void setupBouncingObject({
    bool enabled = true,
    double reflectFactor = 1.0,
  }) {
    _bouncingObjectEnabled = enabled;
    _bouncingReflectFactor = reflectFactor;
  }

  bool onBouncingCollision(PositionComponent other) {
    return other is! Sensor;
  }

  @override
  void onBlockedMovement(
    PositionComponent other,
    Direction? direction,
    Vector2 lastDisplacement,
  ) {
    if (onBouncingCollision(other) &&
        !velocity.isZero() &&
        _bouncingObjectEnabled) {
      if (direction == Direction.left || direction == Direction.right) {
        velocity.x = velocity.x * -_bouncingReflectFactor;
      } else if (direction == Direction.up || direction == Direction.down) {
        velocity.y = velocity.y * -_bouncingReflectFactor;
      } else {
        stopMove();
      }
    } else {
      super.onBlockedMovement(other, direction, lastDisplacement);
    }
  }
}
