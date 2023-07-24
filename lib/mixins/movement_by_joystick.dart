import 'dart:math';

import 'package:bonfire/bonfire.dart';

enum MovementByJoystickType { direction, angle }

/// Mixin responsible for adding movements through joystick events
mixin MovementByJoystick on Movement, JoystickListener {
  JoystickMoveDirectional _currentDirectional = JoystickMoveDirectional.IDLE;
  JoystickMoveDirectional _newDirectional = JoystickMoveDirectional.IDLE;
  double _currentDirectionalAngle = 0;
  double _joystickAngle = 0;
  double _lastSpeed = 0;
  double get _lastSpeedDiagonal => _lastSpeed * Movement.diaginalReduction;

  /// the angle the player should move in 360 mode
  double movementRadAngle = 0;

  bool enabledJoystickIntencity = false;
  bool enabledDiagonalMovements = true;
  bool movementByJoystickEnabled = true;

  /// MovementByJoystickType.direction if you only want the 8 directions movement. Set MovementByJoystickType.angle to have full 360 movement
  MovementByJoystickType moveJoystickType = MovementByJoystickType.direction;
  double _intencity = 1;
  double get intencitySpeed => speed * _intencity;
  bool _isIdle = true;

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    if (enabledJoystickIntencity) {
      _intencity = event.intensity;
    } else {
      _intencity = 1;
    }
    _joystickAngle = event.radAngle;
    _newDirectional = _getDirectional(event.directional);

    super.joystickChangeDirectional(event);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isEnabled()) {
      _handleChangeDirectional();
      if (moveJoystickType == MovementByJoystickType.direction) {
        _moveDirectional(_currentDirectional, intencitySpeed);
      } else {
        _moveAngle(intencitySpeed);
      }
    }
  }

  void _handleChangeDirectional() {
    if (_newDirectional != _currentDirectional &&
        moveJoystickType == MovementByJoystickType.direction) {
      _toCorrectDirection(_newDirectional);
    }
    _currentDirectional = _newDirectional;
    if (moveJoystickType == MovementByJoystickType.direction ||
        _joystickAngle == 0) {
      _currentDirectionalAngle = _getAngleByDirectional(_currentDirectional);
    } else {
      _currentDirectionalAngle = _joystickAngle;
    }

    if (_currentDirectional != JoystickMoveDirectional.IDLE) {
      movementRadAngle = _currentDirectionalAngle;
    }
  }

  void _moveDirectional(
    JoystickMoveDirectional direction,
    double speed,
  ) {
    _lastSpeed = speed;
    switch (direction) {
      case JoystickMoveDirectional.MOVE_UP:
        moveUp(speed: speed);
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        moveUpLeft(speed: speed);
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        moveUpRight(speed: speed);
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        moveRight(speed: speed);
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        moveDown(speed: speed);
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        moveDownRight(speed: speed);
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        moveDownLeft(speed: speed);
        _isIdle = false;
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        moveLeft(speed: speed);
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

  void _moveAngle(double speed) {
    if (_currentDirectional != JoystickMoveDirectional.IDLE) {
      _isIdle = false;
      moveFromAngle(movementRadAngle, speed: speed);
    } else {
      if (!_isIdle) {
        _isIdle = true;
        stopMove(forceIdle: true);
      }
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
    velocity.sub(_getDirectionalVelocity(_currentDirectional));
    velocity.add(_getDirectionalVelocity(directional));
  }

  Vector2 _getDirectionalVelocity(JoystickMoveDirectional directional) {
    switch (directional) {
      case JoystickMoveDirectional.MOVE_UP:
        return Vector2(0, -_lastSpeed);
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        return Vector2(-_lastSpeedDiagonal, -_lastSpeedDiagonal);
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        return Vector2(_lastSpeedDiagonal, -_lastSpeedDiagonal);
      case JoystickMoveDirectional.MOVE_RIGHT:
        return Vector2(_lastSpeed, 0);
      case JoystickMoveDirectional.MOVE_DOWN:
        return Vector2(0, _lastSpeed);
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        return Vector2(_lastSpeedDiagonal, _lastSpeedDiagonal);
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        return Vector2(-_lastSpeedDiagonal, _lastSpeedDiagonal);
      case JoystickMoveDirectional.MOVE_LEFT:
        return Vector2(-_lastSpeed, 0);
      case JoystickMoveDirectional.IDLE:
        return Vector2.zero();
    }
  }

  JoystickMoveDirectional _getDirectional(JoystickMoveDirectional directional) {
    switch (directional) {
      case JoystickMoveDirectional.MOVE_UP:
        return directional;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        if (!enabledDiagonalMovements) {
          return JoystickMoveDirectional.MOVE_LEFT;
        } else {
          return directional;
        }
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        if (!enabledDiagonalMovements) {
          return JoystickMoveDirectional.MOVE_RIGHT;
        } else {
          return directional;
        }
      case JoystickMoveDirectional.MOVE_RIGHT:
        return directional;
      case JoystickMoveDirectional.MOVE_DOWN:
        return directional;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        if (!enabledDiagonalMovements) {
          return JoystickMoveDirectional.MOVE_RIGHT;
        } else {
          return directional;
        }
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        if (!enabledDiagonalMovements) {
          return JoystickMoveDirectional.MOVE_LEFT;
        } else {
          return directional;
        }
      case JoystickMoveDirectional.MOVE_LEFT:
        return directional;
      case JoystickMoveDirectional.IDLE:
        return directional;
    }
  }
}
