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
  Vector2 getCollisionVelocityReflection(
    PositionComponent other,
    CollisionData data,
  ) {
    if (_bouncingObjectEnabled && onBouncingCollision(other)) {
      return super.getCollisionVelocityReflection(other, data) *
          _bouncingReflectFactor;
    }
    return super.getCollisionVelocityReflection(other, data);
  }

  @override
  void onMount() {
    setupBlockMovementCollision(reflectionEnabled: true);
    super.onMount();
  }
}
