import 'package:bonfire/bonfire.dart';

enum JumpingStateEnum {
  up,
  down,
  idle,
}

mixin Jumper on Movement, BlockMovementCollision {
  bool jumping = false;
  int _maxJump = 1;
  int _currentJumps = 0;
  JumpingStateEnum? _lastDirectionJump = JumpingStateEnum.idle;

  void onJump(JumpingStateEnum direction) {}

  void setupJumper({int maxJump = 1}) {
    _maxJump = maxJump;
  }

  void jump({double? speed, bool force = false}) {
    if (!jumping || _currentJumps < _maxJump || force) {
      _currentJumps++;
      moveUp(speed: speed);
      jumping = true;
    }
  }

  @override
  void onBlockedMovement(PositionComponent other, Direction? direction) {
    if (jumping &&
        lastDirectionVertical != Direction.up &&
        direction == Direction.down) {
      _currentJumps = 0;
      jumping = false;
    }
    super.onBlockedMovement(other, direction);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!jumping) {
      jumping = lastDisplacement.y.abs() > 1;
    }
    _notifyJump();
  }

  void _notifyJump() {
    JumpingStateEnum newDirection;
    if (jumping) {
      if (lastDisplacement.y > 0) {
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
