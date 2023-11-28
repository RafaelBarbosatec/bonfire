import 'package:bonfire/bonfire.dart';

// Mixin responsable to give the bounce behavior. (experimental)
mixin BouncingObject on BlockMovementCollision {
  final _countFrameCOllisionDiabledAfterBounce = 4;
  double _bouncingReflectFactor = 1.0;
  bool _bouncingObjectEnabled = true;
  int? _countFrameCollisionStoped;

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
  void onBlockedMovement(
    PositionComponent other,
    CollisionData collisionData,
  ) {
    if (onBouncingCollision(other) && !isStopped() && _bouncingObjectEnabled) {
      if (collisionData.direction == Direction.left || collisionData.direction == Direction.right) {
        velocity.x = velocity.x * -_bouncingReflectFactor;
      } else if (collisionData.direction == Direction.up || collisionData.direction == Direction.down) {
        velocity.y = velocity.y * -_bouncingReflectFactor;
      } else {
        stopMove();
      }
      _countFrameCollisionStoped = 0;
    } else {
      super.onBlockedMovement(other, collisionData);
    }
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    if (_countFrameCollisionStoped != null) {
      return false;
    }
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    if (_countFrameCollisionStoped != null &&
        _countFrameCollisionStoped! <= _countFrameCOllisionDiabledAfterBounce) {
      _countFrameCollisionStoped = _countFrameCollisionStoped! + 1;
    } else {
      _countFrameCollisionStoped = null;
    }
    super.update(dt);
  }
}
