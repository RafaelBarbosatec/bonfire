import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding movements through joystick events
mixin MovementByJoystick on Movement, JoystickListener {
  JoystickMoveDirectional _currentDirectional = JoystickMoveDirectional.IDLE;
  double _currentDirectionalAngle = 0;

  /// flag to set if you only want the 8 directions movement. Set to false to have full 360 movement
  bool dPadAngles = true;

  /// the angle the player should move in 360 mode
  double movementRadAngle = 0;

  bool _isIdleJoystick = true;

  bool enabledDiagonalMovements = true;
  bool movementByJoystickEnabled = true;

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    _currentDirectional = event.directional;
    if (dPadAngles || event.radAngle == 0) {
      _currentDirectionalAngle = _getAngleByDirectional(_currentDirectional);
    } else {
      _currentDirectionalAngle = event.radAngle;
    }

    if (_currentDirectional != JoystickMoveDirectional.IDLE) {
      movementRadAngle = _currentDirectionalAngle;
    }
    super.joystickChangeDirectional(event);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isEnabled()) {
      if (dPadAngles) {
        _moveDirectional(_currentDirectional, speed);
      } else {
        if (_currentDirectional != JoystickMoveDirectional.IDLE) {
          _isIdleJoystick = false;
          moveFromAngle(speed, movementRadAngle);
        }
      }
    }
  }

  void _moveDirectional(
    JoystickMoveDirectional direction,
    double speed,
  ) {
    switch (direction) {
      case JoystickMoveDirectional.MOVE_UP:
        _isIdleJoystick = false;
        moveUp(speed);
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        _isIdleJoystick = false;
        if (enabledDiagonalMovements) {
          moveUpLeft(speed, speed);
        } else {
          moveLeft(speed);
        }
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        _isIdleJoystick = false;
        if (enabledDiagonalMovements) {
          moveUpRight(speed, speed);
        } else {
          moveRight(speed);
        }
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
        if (enabledDiagonalMovements) {
          moveDownRight(speed, speed);
        } else {
          moveRight(speed);
        }
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        _isIdleJoystick = false;
        if (enabledDiagonalMovements) {
          moveDownLeft(speed, speed);
        } else {
          moveLeft(speed);
        }
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

  double _getAngleByDirectional(JoystickMoveDirectional directional) {
    switch (directional) {
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
    if (gameRef.joystick is Joystick) {
      (gameRef.joystick as Joystick).resetDirectionalKeys();
    }

    _currentDirectional = JoystickMoveDirectional.IDLE;
    super.idle();
  }

  bool _isEnabled() {
    return (gameRef.joystick?.containObserver(this) ?? false) &&
        movementByJoystickEnabled;
  }
}
