import 'package:bonfire/bonfire.dart';

enum MovementByJoystickType { direction, angle }

class MovementByJoystickProps {
  /// MovementByJoystickType.direction if you only want the
  ///  8 directions movement.
  ///  Set MovementByJoystickType.angle to have full 360 movement
  MovementByJoystickType moveType;
  bool intensityEnabled;
  bool diagonalEnabled;
  bool enabled;
  MovementByJoystickProps({
    this.moveType = MovementByJoystickType.direction,
    this.intensityEnabled = false,
    this.diagonalEnabled = true,
    this.enabled = true,
  });
}

/// Mixin responsible for adding movements through joystick events
mixin MovementByJoystick on Movement, PlayerControllerListener {
  JoystickMoveDirectional _currentDirectional = JoystickMoveDirectional.IDLE;
  JoystickMoveDirectional _newDirectional = JoystickMoveDirectional.IDLE;
  double _currentDirectionalAngle = 0;
  double _joystickAngle = 0;
  double _lastSpeed = 0;
  double get _lastSpeedDiagonal => _lastSpeed * Movement.diaginalReduction;

  /// the angle the player should move in 360 mode
  double movementByJoystickRadAngle = 0;

  MovementByJoystickProps _settings = MovementByJoystickProps();

  void setupMovementByJoystick({
    MovementByJoystickType moveType = MovementByJoystickType.direction,
    bool intensityEnabled = false,
    bool diagonalEnabled = true,
    bool enabled = true,
  }) {
    _settings = MovementByJoystickProps(
      moveType: moveType,
      intensityEnabled: intensityEnabled,
      diagonalEnabled: diagonalEnabled,
      enabled: enabled,
    );
  }

  double _intensity = 1;
  double get _intensitySpeed => speed * _intensity;
  bool _isIdle = true;

  bool get _isMoveByDirection =>
      _settings.moveType == MovementByJoystickType.direction;

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    if (_settings.intensityEnabled) {
      _intensity = event.intensity;
    } else {
      _intensity = 1;
    }
    _joystickAngle = event.radAngle;
    _newDirectional = _getDirectional(event.directional);

    super.onJoystickChangeDirectional(event);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_settings.enabled) {
      _handleChangeDirectional();
      if (_isMoveByDirection) {
        _moveDirectional(_currentDirectional, _intensitySpeed);
      } else {
        _moveAngle(_intensitySpeed);
      }
    }
  }

  void _handleChangeDirectional() {
    if (_newDirectional != _currentDirectional && _isMoveByDirection) {
      _toCorrectDirection(_newDirectional);
    }
    _currentDirectional = _newDirectional;
    if (_isMoveByDirection || _joystickAngle == 0) {
      _currentDirectionalAngle = _currentDirectional.radAngle;
    } else {
      _currentDirectionalAngle = _joystickAngle;
    }

    if (_currentDirectional != JoystickMoveDirectional.IDLE) {
      movementByJoystickRadAngle = _currentDirectionalAngle;
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
      moveFromAngle(movementByJoystickRadAngle, speed: speed);
    } else {
      if (!_isIdle) {
        _isIdle = true;
        stopMove(forceIdle: true);
      }
    }
  }

  @override
  void idle() {
    _currentDirectional = JoystickMoveDirectional.IDLE;
    _newDirectional = JoystickMoveDirectional.IDLE;
    _currentDirectionalAngle = 0;
    _joystickAngle = 0;
    _lastSpeed = 0;
    super.idle();
  }

  void _toCorrectDirection(JoystickMoveDirectional directional) {
    velocity.sub(_getRestDirectionalVelocity(_currentDirectional));
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

  double _getRestYVelocity(double speed) {
    if (velocity.y.abs() >= speed) {
      return speed;
    } else {
      return velocity.y.abs();
    }
  }

  double _getRestXVelocity(double speed) {
    if (velocity.x.abs() >= speed) {
      return speed;
    } else {
      return velocity.x.abs();
    }
  }

  Vector2 _getRestDirectionalVelocity(JoystickMoveDirectional directional) {
    switch (directional) {
      case JoystickMoveDirectional.MOVE_UP:
        return Vector2(0, -_getRestYVelocity(_lastSpeed));
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        return Vector2(
          -_getRestXVelocity(_lastSpeedDiagonal),
          -_getRestYVelocity(_lastSpeedDiagonal),
        );
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        return Vector2(
          _getRestXVelocity(_lastSpeedDiagonal),
          -_getRestYVelocity(_lastSpeedDiagonal),
        );
      case JoystickMoveDirectional.MOVE_RIGHT:
        return Vector2(_getRestXVelocity(_lastSpeed), 0);
      case JoystickMoveDirectional.MOVE_DOWN:
        return Vector2(0, _getRestYVelocity(_lastSpeed));
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        return Vector2(
          _getRestXVelocity(_lastSpeedDiagonal),
          _getRestYVelocity(_lastSpeedDiagonal),
        );
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        return Vector2(
          -_getRestXVelocity(_lastSpeedDiagonal),
          _getRestYVelocity(_lastSpeedDiagonal),
        );
      case JoystickMoveDirectional.MOVE_LEFT:
        return Vector2(-_getRestXVelocity(_lastSpeed), 0);
      case JoystickMoveDirectional.IDLE:
        return Vector2.zero();
    }
  }

  JoystickMoveDirectional _getDirectional(JoystickMoveDirectional directional) {
    switch (directional) {
      case JoystickMoveDirectional.MOVE_UP:
        return directional;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        if (!_settings.diagonalEnabled) {
          return JoystickMoveDirectional.MOVE_LEFT;
        } else {
          return directional;
        }
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        if (!_settings.diagonalEnabled) {
          return JoystickMoveDirectional.MOVE_RIGHT;
        } else {
          return directional;
        }
      case JoystickMoveDirectional.MOVE_RIGHT:
        return directional;
      case JoystickMoveDirectional.MOVE_DOWN:
        return directional;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        if (!_settings.diagonalEnabled) {
          return JoystickMoveDirectional.MOVE_RIGHT;
        } else {
          return directional;
        }
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        if (!_settings.diagonalEnabled) {
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
