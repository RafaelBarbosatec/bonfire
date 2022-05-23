import 'dart:math';

import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/mixins/movement.dart';

/// Mixin responsible for adding movements through joystick events
mixin MovementByJoystick on Movement {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;

  /// flag to set if you only want the 8 directions movement. Set to false to have full 360 movement
  bool dPadAngles = true;

  /// the angle the player should move in 360 mode
  double movementRadAngle = 0;

  bool _isIdleJoystick = true;

  @override
  void update(double dt) {
    if (this is JoystickListener) {
      bool joystickContainThisComponent =
          gameRef.joystick?.containObserver(this as JoystickListener) ?? false;

      var newAngle = innerCurrentDirectionalAngle;
      if (dPadAngles || newAngle == 0.0) {
        newAngle = _getAngleByDirectional();
      }
      if (innerCurrentDirectional != JoystickMoveDirectional.IDLE &&
          newAngle != 0.0) {
        movementRadAngle = newAngle;
      }

      if (dPadAngles) {
        if (innerCurrentDirectional != null && joystickContainThisComponent) {
          final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;
          _moveDirectional(innerCurrentDirectional!, speed, diagonalSpeed);
        }
      } else {
        if (innerCurrentDirectional != null && joystickContainThisComponent) {
          if (innerCurrentDirectional != JoystickMoveDirectional.IDLE) {
            _isIdleJoystick = false;
            moveFromAngle(speed, movementRadAngle);
          }
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
        _isIdleJoystick = false;
        moveUp(speed);
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        _isIdleJoystick = false;
        moveUpLeft(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        _isIdleJoystick = false;
        moveUpRight(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        _isIdleJoystick = false;
        moveRight(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        _isIdleJoystick = false;
        moveDown(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        _isIdleJoystick = false;
        moveDownRight(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        _isIdleJoystick = false;
        moveDownLeft(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        _isIdleJoystick = false;
        moveLeft(speed);
        break;
      case JoystickMoveDirectional.IDLE:
        if (!_isIdleJoystick) {
          _isIdleJoystick = true;
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

  /// get currentDirectional from `JoystickListener`
  double get innerCurrentDirectionalAngle {
    if (this is JoystickListener) {
      return (this as JoystickListener).currentDirectionalAngle;
    } else {
      return 0;
    }
  }

  double _getAngleByDirectional() {
    switch (innerCurrentDirectional) {
      case JoystickMoveDirectional.MOVE_LEFT:
        return 180 / (180 / pi);
      case JoystickMoveDirectional.MOVE_RIGHT:
        // we can't use 0 here because then no movement happens
        // we're just going as close to 0.0 without being exactly 0.0
        // if you have a better idea. Please be my guest
        return 0.0000001 / (180 / pi);
      case JoystickMoveDirectional.MOVE_UP:
        return -90 / (180 / pi);
      case JoystickMoveDirectional.MOVE_DOWN:
        return 90 / (180 / pi);
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        return -135 / (180 / pi);
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        return -45 / (180 / pi);
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        return 135 / (180 / pi);
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        return 45 / (180 / pi);
      default:
        return 0;
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
