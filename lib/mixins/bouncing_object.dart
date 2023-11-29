import 'package:bonfire/bonfire.dart';

// Mixin responsable to give the bounce behavior. (experimental)
mixin BouncingObject on BlockMovementCollision {
  double _bouncingReflectFactor = 2.0;
  bool _bouncingObjectEnabled = true;

  void setupBouncingObject({
    bool enabled = true,
    double reflectFactor = 1.0,
  }) {
    _bouncingObjectEnabled = enabled;
    _bouncingReflectFactor = reflectFactor;
  }

  bool onBouncingCollision(PositionComponent other) {
    return true;
  }

  @override
  void onBlockMovementUpdateVelocity(
    PositionComponent other,
    CollisionData collisionData,
  ) {
    if (onBouncingCollision(other) && !isStopped() && _bouncingObjectEnabled) {
      velocity = velocity -
          Vector2(
                velocity.x * collisionData.normal.x.abs(),
                velocity.y * collisionData.normal.y.abs(),
              ) *
              _bouncingReflectFactor;
    } else {
      super.onBlockMovementUpdateVelocity(other, collisionData);
    }
  }
}
