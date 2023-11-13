import 'package:bonfire/bonfire.dart';

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
mixin Jumper on Movement, BlockMovementCollision {
  final double _defaultJumpSpeed = 150;
  bool jumping = false;
  JumpingStateEnum jumpingState = JumpingStateEnum.idle;
  int _maxJump = 1;
  int _currentJumps = 0;
  JumpingStateEnum? _lastDirectionJump = JumpingStateEnum.idle;

  void onJump(JumpingStateEnum state) {
    jumpingState = state;
  }

  void setupJumper({int maxJump = 1}) {
    _maxJump = maxJump;
  }

  void jump({double? jumpSpeed, bool force = false}) {
    if (!jumping || _currentJumps < _maxJump || force) {
      _currentJumps++;
      moveUp(speed: jumpSpeed ?? _defaultJumpSpeed);
      jumping = true;
    }
  }

  @override
  void onBlockedMovement(
    PositionComponent other,
    Direction direction,
  ) {
    super.onBlockedMovement(other, direction);
    if (jumping && lastDirectionVertical.isDownSide && direction.isDownSide) {
      _currentJumps = 0;
      jumping = false;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!jumping && lastDisplacement.y > 1) {
      jumping = true;
    }
    _notifyJump();
  }

  void _notifyJump() {
    JumpingStateEnum newDirection;
    if (jumping) {
      if (lastDirectionVertical == Direction.down) {
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
}
