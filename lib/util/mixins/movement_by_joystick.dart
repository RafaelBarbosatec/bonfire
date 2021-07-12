import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/mixins/movement.dart';

mixin MovementByJoystick on Movement {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;

  @override
  void update(double dt) {
    if (this is JoystickListener) {
      bool joystickContainThisComponent = gameRef.joystickController
              ?.containObserver(this as JoystickListener) ??
          false;
      if (innerCurrentDirectional != null && joystickContainThisComponent) {
        final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;

        switch (innerCurrentDirectional!) {
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
    }

    super.update(dt);
  }

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
