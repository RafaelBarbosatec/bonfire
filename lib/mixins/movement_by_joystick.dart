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

  bool enabledJoystickIntencity = false;
  bool enabledDiagonalMovements = true;
  bool movementByJoystickEnabled = true;
  double _intencity = 1;
  bool _isIdle = true;

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    _intencity = event.intensity;
    _toCorrectDirection(event.directional);
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
          _isIdle = false;
          moveFromAngle(movementRadAngle);
        } else {
          if (!_isIdle) {
            _isIdle = true;
            stopMove(forceIdle: true);
          }
        }
      }
    }
  }

  void _moveDirectional(
    JoystickMoveDirectional direction,
    double speed,
  ) {
    double intensity = 1;
    if (enabledJoystickIntencity) {
      intensity = _intencity;
    }
    switch (direction) {
      case JoystickMoveDirectional.MOVE_UP:
        moveUp(speed: speed * intensity);
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        if (enabledDiagonalMovements) {
          moveUpLeft(speed: speed * intensity);
        } else {
          moveLeft(speed: speed * intensity);
        }
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        if (enabledDiagonalMovements) {
          moveUpRight(speed: speed * intensity);
        } else {
          moveRight(speed: speed * intensity);
        }
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        moveRight(speed: speed * intensity);
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        moveDown(speed: speed * intensity);
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        if (enabledDiagonalMovements) {
          moveDownRight(speed: speed * intensity);
        } else {
          moveRight(speed: speed * intensity);
        }
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        if (enabledDiagonalMovements) {
          moveDownLeft(speed: speed * intensity);
        } else {
          moveLeft(speed: speed * intensity);
        }
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        moveLeft(speed: speed * intensity);
        _isIdle = false;
        break;
      case JoystickMoveDirectional.IDLE:
        if (!_isIdle) {
          _isIdle = true;
          stopMove(forceIdle: true);
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
    _currentDirectional = JoystickMoveDirectional.IDLE;
    super.idle();
  }

  bool _isEnabled() {
    return (gameRef.joystick?.containObserver(this) ?? false) &&
        movementByJoystickEnabled;
  }

  void _toCorrectDirection(JoystickMoveDirectional directional) {
    if (directional == JoystickMoveDirectional.MOVE_LEFT &&
        _currentDirectional == JoystickMoveDirectional.MOVE_UP_LEFT) {
      velocity = velocity.copyWith(y: 0);
    }
    if (directional == JoystickMoveDirectional.MOVE_RIGHT &&
        _currentDirectional == JoystickMoveDirectional.MOVE_UP_RIGHT) {
      velocity = velocity.copyWith(y: 0);
    }

    if (directional == JoystickMoveDirectional.MOVE_RIGHT &&
        _currentDirectional == JoystickMoveDirectional.MOVE_DOWN_RIGHT) {
      velocity = velocity.copyWith(y: 0);
    }

    if (directional == JoystickMoveDirectional.MOVE_LEFT &&
        _currentDirectional == JoystickMoveDirectional.MOVE_DOWN_LEFT) {
      velocity = velocity.copyWith(y: 0);
    }

    //==========================

    if (directional == JoystickMoveDirectional.MOVE_UP &&
        _currentDirectional == JoystickMoveDirectional.MOVE_UP_LEFT) {
      velocity = velocity.copyWith(x: 0);
    }
    if (directional == JoystickMoveDirectional.MOVE_UP &&
        _currentDirectional == JoystickMoveDirectional.MOVE_UP_RIGHT) {
      velocity = velocity.copyWith(x: 0);
    }

    if (directional == JoystickMoveDirectional.MOVE_DOWN &&
        _currentDirectional == JoystickMoveDirectional.MOVE_DOWN_LEFT) {
      velocity = velocity.copyWith(x: 0);
    }
    if (directional == JoystickMoveDirectional.MOVE_DOWN &&
        _currentDirectional == JoystickMoveDirectional.MOVE_DOWN_RIGHT) {
      velocity = velocity.copyWith(x: 0);
    }
  }
}
