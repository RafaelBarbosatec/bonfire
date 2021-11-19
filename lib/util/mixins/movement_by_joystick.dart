import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/mixins/movement.dart';

/// Mixin responsible for adding movements through joystick events
mixin MovementByJoystick on Movement {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;

  /// flag to set if you only want the 8 directions movement. Set to false to have full 360 movement
  bool dPadAngles = true;

  /// the angle the player should move in 360 mode
  double movementRadAngle = 0;

  @override
  void update(double dt) {
    if (this is JoystickListener) {
      bool joystickContainThisComponent =
          gameRef.joystick?.containObserver(this as JoystickListener) ?? false;
      if (dPadAngles) {
        if (innerCurrentDirectional != null && joystickContainThisComponent) {
          final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;
          _moveDirectional(innerCurrentDirectional!, speed, diagonalSpeed);
        }
      } else {
        if (innerCurrentDirectional != null && joystickContainThisComponent) {
          if (innerCurrentDirectional != JoystickMoveDirectional.IDLE) {
            moveFromAngle(speed, movementRadAngle);
          }
          // movement was done on the above line, this is only for the animation
          // which is why we use zero speed as we don't want to translate position twice
          _moveDirectional(innerCurrentDirectional!, 0, 0);
        }
      }
    }

    super.update(dt);
  }

  void _moveDirectional(
    JoystickMoveDirectional direction,
    double speed,
    double diagonalSpeed,
  ) {
    switch (direction) {
      case JoystickMoveDirectional.MOVE_UP:
        moveUp(speed);
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        moveUpLeft(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        moveUpRight(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        moveRight(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        moveDown(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        moveDownRight(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        moveDownLeft(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        moveLeft(speed);
        break;
      case JoystickMoveDirectional.IDLE:
        if (!isIdle) {
          idle();
        }
        break;
    }
  }

  /// get currentDirectional from `JoystickListener`
  JoystickMoveDirectional? get innerCurrentDirectional {
    if (this is JoystickListener) {
      return (this as JoystickListener).currentDirectional;
    } else {
      print(
          '(MovementByJoystick) ERROR: $this need use JoystickListener mixin');
      return null;
    }
  }

  @override
  void idle() {
    if (this is JoystickListener) {
      (this as JoystickListener).currentDirectional =
          JoystickMoveDirectional.IDLE;
    }
    super.idle();
  }
}
