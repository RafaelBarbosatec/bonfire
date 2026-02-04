// ignore_for_file: use_setters_to_change_properties

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision_game_component.dart';

enum JumpingStateEnum {
  up,
  down,
  idle,
}

/// Mixin used to adds the jumper behavior. It's useful to platform games.
/// OBS: It's needed adds a force to simulate gravity like. Example:
/// BonfireWidget(
///   globalForces: [
///     GravityForce2D(),
///   ],
/// )
mixin Jumper on Movement, SimpleCollision {
  final double _defaultJumpSpeed = 150;
  bool isJumping = false;
  JumpingStateEnum jumpingState = JumpingStateEnum.idle;
  int _maxJump = 1;
  int _currentJumps = 0;
  JumpingStateEnum? _lastDirectionJump = JumpingStateEnum.idle;
  int _tileCollisionCount = 0;

  static const _tileCollisionCountKey = 'tileCollisionCount';

  void onJump(JumpingStateEnum state) {
    jumpingState = state;
  }

  void setupJumper({int maxJump = 1}) {
    _maxJump = maxJump;
  }

  void jump({double? jumpSpeed, bool force = false}) {
    if (!isJumping || _currentJumps < _maxJump || force) {
      _currentJumps++;
      moveUp(speed: jumpSpeed ?? _defaultJumpSpeed);
      isJumping = true;
    }
  }

  @override
  void onMovementBlocked(PositionComponent other, CollisionData collisionData) {
    if (isJumping && collisionData.direction.isDownSide) {
      _currentJumps = 0;
      isJumping = false;
    }
    super.onMovementBlocked(other, collisionData);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is CollisionMapComponent || other is TileWithCollision) {
      ++_tileCollisionCount;
      resetInterval(_tileCollisionCountKey);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is CollisionMapComponent || other is TileWithCollision) {
      if (--_tileCollisionCount == 0) {
        resetInterval(_tileCollisionCountKey);
      }
    }
    super.onCollisionEnd(other);
  }

  @override
  void update(double dt) {
    final tick = checkInterval(
      _tileCollisionCountKey,
      100,
      dt,
      firstCheckIsTrue: false,
    );
    if (tick) {
      if (!isJumping && _tileCollisionCount == 0 && velocity.y > 0.2) {
        isJumping = true;
      }
    }
    _notifyJump();
    super.update(dt);
  }

  void _notifyJump() {
    JumpingStateEnum newDirection;
    if (isJumping) {
      if (direction.isDownSide) {
        newDirection = JumpingStateEnum.down;
      } else {
        newDirection = JumpingStateEnum.up;
      }
    } else {
      newDirection = JumpingStateEnum.idle;
    }
    if (newDirection != _lastDirectionJump) {
      _lastDirectionJump = newDirection;
      onJump(newDirection);
    }
  }

  @override
  void stop() {
    if (!isJumping) {
      super.stop();
    }
  }
}
