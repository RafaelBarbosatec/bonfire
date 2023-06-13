import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding movements
mixin Movement on GameComponent {
  static const diaginalReduction = 0.7853981633974483;

  bool get isIdle => _velocity.isZero();
  double dtUpdate = 0;
  double speed = 100;
  double _lastSpeed = 100;
  double velocityRadAngle = 0.0;
  Vector2 lastDisplacement = Vector2.zero();
  Vector2 _velocity = Vector2.zero();
  Direction lastDirection = Direction.right;
  Direction lastDirectionHorizontal = Direction.right;
  Direction lastDirectionVertical = Direction.down;
  bool movementOnlyVisible = true;

  Vector2 get velocity => _velocity;
  set velocity(Vector2 velocity) {
    _velocity = velocity;
    _updateLastDirection(_velocity);
  }

  /// You can override this method to listen the movement of this component
  void onMove(
    double speed,
    Vector2 displacement,
    Direction direction,
    double angle,
  ) {}

  Vector2 onApplyVelocity(Vector2 velocity, double dt) {
    return velocity * dt;
  }

  /// Method used to translate component
  void translate(Vector2 displacement) {
    lastDisplacement = displacement;
    _updateLastDirection(lastDisplacement);
    position.add(displacement);
  }

  void moveLeftOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    position += lastDisplacement = Vector2(-_lastSpeed, 0) * dtUpdate;
    _updateLastDirection(lastDisplacement);
  }

  void moveRightOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    position += lastDisplacement = Vector2(_lastSpeed, 0) * dtUpdate;
    _updateLastDirection(lastDisplacement);
  }

  void moveUpOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    position += lastDisplacement = Vector2(0, -_lastSpeed) * dtUpdate;
    _updateLastDirection(lastDisplacement);
  }

  void moveDownOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    position += lastDisplacement = Vector2(0, _lastSpeed) * dtUpdate;
    _updateLastDirection(lastDisplacement);
  }

  /// Move player to Up
  void moveUp({double? speed, bool setZeroCrossVelocity = false}) {
    _lastSpeed = speed ?? this.speed;
    _velocity = _velocity.copyWith(
      y: -_lastSpeed,
      x: setZeroCrossVelocity ? 0.0 : _velocity.x,
    );
    _updateLastDirection(_velocity);
  }

  /// Move player to Down
  void moveDown({double? speed, bool setZeroCrossVelocity = false}) {
    _lastSpeed = speed ?? this.speed;
    _velocity = _velocity.copyWith(
      y: _lastSpeed,
      x: setZeroCrossVelocity ? 0.0 : _velocity.x,
    );
    _updateLastDirection(_velocity);
  }

  /// Move player to Left
  void moveLeft({double? speed, bool setZeroCrossVelocity = false}) {
    _lastSpeed = speed ?? this.speed;
    _velocity = _velocity.copyWith(
      x: -_lastSpeed,
      y: setZeroCrossVelocity ? 0.0 : _velocity.y,
    );
    _updateLastDirection(_velocity);
  }

  /// Move player to Right
  void moveRight({double? speed, bool setZeroCrossVelocity = false}) {
    _lastSpeed = speed ?? this.speed;
    _velocity = _velocity.copyWith(
      x: _lastSpeed,
      y: setZeroCrossVelocity ? 0.0 : _velocity.y,
    );
    _updateLastDirection(_velocity);
  }

  /// Move player to Up and Right
  void moveUpRight({double? speed}) {
    _lastSpeed = speed ?? this.speed * diaginalReduction;
    _velocity = Vector2(_lastSpeed, -_lastSpeed);
    _updateLastDirection(_velocity);
  }

  /// Move player to Up and Left
  void moveUpLeft({double? speed}) {
    _lastSpeed = speed ?? this.speed * diaginalReduction;
    _velocity = Vector2(-_lastSpeed, -_lastSpeed);
    _updateLastDirection(_velocity);
  }

  /// Move player to Down and Left
  void moveDownLeft({double? speed}) {
    _lastSpeed = speed ?? this.speed * diaginalReduction;
    _velocity = Vector2(-_lastSpeed, _lastSpeed);
    _updateLastDirection(_velocity);
  }

  /// Move player to Down and Right
  void moveDownRight({double? speed}) {
    _lastSpeed = speed ?? this.speed * diaginalReduction;
    _velocity = Vector2(_lastSpeed, _lastSpeed);
    _updateLastDirection(_velocity);
  }

  /// Move Player to direction by radAngle
  void moveFromAngle(double angle, {double? speed}) {
    _lastSpeed = speed ?? this.speed;
    _velocity = Vector2(cos(angle) * _lastSpeed, sin(angle) * _lastSpeed);
    _updateLastDirection(_velocity);
  }

  void stopMove({bool forceIdle = false, bool isX = true, bool isY = true}) {
    if (isIdle && !forceIdle) return;
    setZeroVelocity(isX: isX, isY: isY);
    idle();
  }

  void idle() {}

  void setZeroVelocity({bool isX = true, bool isY = true}) {
    _velocity = _velocity.copyWith(
      x: isX ? 0.0 : _velocity.x,
      y: isY ? 0.0 : _velocity.y,
    );
    if (isX && isY) {
      velocityRadAngle = 0.0;
    }
  }

  void stopFromCollision({bool isX = true, bool isY = true}) {
    setZeroVelocity(isX: isX, isY: isY);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isVisible || !movementOnlyVisible) {
      _updatePosition(dt);
    }
  }

  void moveFromDirection(
    Direction direction, {
    Vector2? speedVector,
    bool enabledDiagonal = true,
  }) {
    switch (direction) {
      case Direction.left:
        moveLeft();
        break;
      case Direction.right:
        moveRight();
        break;
      case Direction.up:
        moveUp();
        break;
      case Direction.down:
        moveDown();
        break;
      case Direction.upLeft:
        if (enabledDiagonal) {
          moveUpLeft();
        } else {
          moveRight();
        }
        break;
      case Direction.upRight:
        if (enabledDiagonal) {
          moveUpRight();
        } else {
          moveRight();
        }
        break;
      case Direction.downLeft:
        if (enabledDiagonal) {
          moveDownLeft();
        } else {
          moveLeft();
        }
        break;
      case Direction.downRight:
        if (enabledDiagonal) {
          moveDownRight();
        } else {
          moveRight();
        }
        break;
    }
  }

  void _updateLastDirection(Vector2 direction) {
    velocityRadAngle = atan2(direction.y, direction.x);

    if (direction.x > 0) {
      lastDirectionHorizontal = Direction.right;
    } else if (direction.x < 0) {
      lastDirectionHorizontal = Direction.left;
    }

    if (direction.y > 0) {
      lastDirectionVertical = Direction.down;
    } else if (direction.y < 0) {
      lastDirectionVertical = Direction.up;
    }

    if (direction.y != 0 && direction.x == 0) {
      if (direction.y > 0) {
        lastDirection = Direction.down;
      } else if (direction.y < 0) {
        lastDirection = Direction.up;
      }
      return;
    }
    if (direction.x != 0 && direction.y == 0) {
      if (direction.x > 0) {
        lastDirection = Direction.right;
      } else if (direction.x < 0) {
        lastDirection = Direction.left;
      }
      return;
    }

    if (direction.x > 0 && direction.y > 0) {
      lastDirection = Direction.downRight;
    } else if (direction.x > 0 && direction.y < 0) {
      lastDirection = Direction.upRight;
    } else if (direction.x < 0 && direction.y > 0) {
      lastDirection = Direction.downLeft;
    } else if (direction.x < 0 && direction.y < 0) {
      lastDirection = Direction.upLeft;
    }
  }

  void _requestUpdatePriority() {
    if (hasGameRef) {
      (gameRef as BonfireGame).requestUpdatePriority();
    }
  }

  void _updatePosition(double dt) {
    position += lastDisplacement = onApplyVelocity(_velocity, dt);
    dtUpdate = dt;
    if (!lastDisplacement.isZero()) {
      if (lastDirection == Direction.up || lastDirection == Direction.down) {
        _requestUpdatePriority();
      }
      onMove(_lastSpeed, lastDisplacement, lastDirection, velocityRadAngle);
    }
  }
}
