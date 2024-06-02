import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding movements
mixin Movement on GameComponent {
  static const diaginalReduction = 0.7853981633974483;
  static const speedDefault = 80.0;
  double minDisplacementToConsiderMove = 0.1;
  double dtUpdate = 0;
  double speed = speedDefault;
  double _lastSpeed = speedDefault;
  double velocityRadAngle = 0.0;
  Vector2 displacement = Vector2.zero();
  Vector2 _velocity = Vector2.zero();
  Direction lastDirection = Direction.right;
  Direction lastDirectionHorizontal = Direction.right;
  Direction lastDirectionVertical = Direction.down;
  bool movementOnlyVisible = true;

  Vector2 get acceleration => velocity / dtUpdate;

  bool get isIdle => _velocity.isZero();
  Vector2 get velocity => _velocity;
  double get diagonalSpeed => speed * diaginalReduction;
  double get dtSpeed => speed * dtUpdate;
  double get dtDiagonalSpeed => diagonalSpeed * dtUpdate;
  set velocity(Vector2 velocity) {
    _velocity = velocity;
    _updateLastDirection(_velocity);
  }

  void setVelocityAxis({double? x, double? y}) {
    _velocity.x = x ?? _velocity.x;
    _velocity.y = y ?? _velocity.y;
  }

  /// You can override this method to listen the movement of this component
  void onMove(
    double speed,
    Vector2 displacement,
    Direction direction,
    double angle,
  ) {}

  Vector2 onVelocityUpdate(double dt, Vector2 velocity) {
    return velocity;
  }

  void onApplyDisplacement(double dt) {
    velocity = onVelocityUpdate(dt, velocity);
    if (!velocity.isZero()) {
      super.position += displacement = velocity * dt;
      _updateLastDirection(velocity);
    } else {
      displacement.setZero();
    }
  }

  void correctPositionFromCollision(Vector2 position) {
    super.position = position;
  }

  @override
  set position(Vector2 newP) {
    translate(newP - this.position);
  }

  /// Method used to translate component
  void translate(Vector2 displacement) {
    this.displacement = displacement;
    _updateLastDirection(displacement);
    position.add(displacement);
  }

  void moveLeftOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(x: -_lastSpeed);
    onApplyDisplacement(dtUpdate);
    _velocity.add(Vector2(_lastSpeed, 0));
    setVelocityAxis(x: 0);
  }

  void moveRightOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(x: _lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(x: 0);
  }

  void moveUpOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(y: -_lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0);
  }

  void moveDownOnce({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(y: _lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0);
  }

  void moveDownRightOnce({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    setVelocityAxis(y: _lastSpeed, x: _lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0, x: 0);
  }

  void moveDownLeftOnce({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    setVelocityAxis(y: _lastSpeed, x: -_lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0, x: 0);
  }

  void moveUpRightOnce({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    setVelocityAxis(y: -_lastSpeed, x: _lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0, x: 0);
  }

  void moveUpLeftOnce({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    setVelocityAxis(y: -_lastSpeed, x: -_lastSpeed);
    onApplyDisplacement(dtUpdate);
    setVelocityAxis(y: 0, x: 0);
  }

  /// Move player to Up
  void moveUp({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(y: -_lastSpeed);
  }

  /// Move player to Down
  void moveDown({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(y: _lastSpeed);
  }

  /// Move player to Left
  void moveLeft({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(x: -_lastSpeed);
  }

  /// Move player to Right
  void moveRight({double? speed}) {
    _lastSpeed = speed ?? this.speed;
    setVelocityAxis(x: _lastSpeed);
  }

  /// Move player to Up and Right
  void moveUpRight({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    velocity = Vector2(_lastSpeed, -_lastSpeed);
  }

  /// Move player to Up and Left
  void moveUpLeft({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    velocity = Vector2(-_lastSpeed, -_lastSpeed);
  }

  /// Move player to Down and Left
  void moveDownLeft({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    velocity = Vector2(-_lastSpeed, _lastSpeed);
  }

  /// Move player to Down and Right
  void moveDownRight({double? speed}) {
    _lastSpeed = (speed ?? this.speed) * diaginalReduction;
    velocity = Vector2(_lastSpeed, _lastSpeed);
  }

  /// Move Player to direction by radAngle
  void moveFromAngle(double angle, {double? speed}) {
    _lastSpeed = speed ?? this.speed;
    velocity = BonfireUtil.vector2ByAngle(angle, intensity: _lastSpeed);
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

  @override
  void update(double dt) {
    dtUpdate = dt;
    super.update(dt);
    if (isVisible || !movementOnlyVisible) {
      _updatePosition(dt);
    }
  }

  void moveFromDirection(
    Direction direction, {
    bool enabledDiagonal = true,
    double? speed,
  }) {
    switch (direction) {
      case Direction.left:
        moveLeft(speed: speed);
        break;
      case Direction.right:
        moveRight(speed: speed);
        break;
      case Direction.up:
        moveUp(speed: speed);
        break;
      case Direction.down:
        moveDown(speed: speed);
        break;
      case Direction.upLeft:
        if (enabledDiagonal) {
          moveUpLeft(speed: speed);
        } else {
          moveRight(speed: speed);
        }
        break;
      case Direction.upRight:
        if (enabledDiagonal) {
          moveUpRight(speed: speed);
        } else {
          moveRight(speed: speed);
        }
        break;
      case Direction.downLeft:
        if (enabledDiagonal) {
          moveDownLeft(speed: speed);
        } else {
          moveLeft(speed: speed);
        }
        break;
      case Direction.downRight:
        if (enabledDiagonal) {
          moveDownRight(speed: speed);
        } else {
          moveRight(speed: speed);
        }
        break;
    }
  }

  void _updateLastDirection(Vector2 velocity) {
    velocityRadAngle = atan2(velocity.y, velocity.x);

    if (velocity.x > 0) {
      lastDirectionHorizontal = Direction.right;
    } else if (velocity.x < 0) {
      lastDirectionHorizontal = Direction.left;
    }

    if (velocity.y > 0) {
      lastDirectionVertical = Direction.down;
    } else if (velocity.y < 0) {
      lastDirectionVertical = Direction.up;
    }

    if (velocity.y != 0 && velocity.x == 0) {
      if (velocity.y > 0) {
        lastDirection = Direction.down;
      } else if (velocity.y < 0) {
        lastDirection = Direction.up;
      }
      return;
    }
    if (velocity.x != 0 && velocity.y == 0) {
      if (velocity.x > 0) {
        lastDirection = Direction.right;
      } else if (velocity.x < 0) {
        lastDirection = Direction.left;
      }
      return;
    }

    var normal = velocity.normalized()..absolute();
    double baseDiagonal = 0.2;

    if (velocity.x > 0 && velocity.y > 0) {
      if (normal.x > baseDiagonal && normal.y > baseDiagonal) {
        lastDirection = Direction.downRight;
      } else if (normal.x > normal.y) {
        lastDirection = Direction.right;
      } else {
        lastDirection = Direction.down;
      }
    } else if (velocity.x > 0 && velocity.y < 0) {
      if (normal.x > baseDiagonal && normal.y > baseDiagonal) {
        lastDirection = Direction.upRight;
      } else if (normal.x > normal.y) {
        lastDirection = Direction.right;
      } else {
        lastDirection = Direction.up;
      }
    } else if (velocity.x < 0 && velocity.y > 0) {
      if (normal.x > baseDiagonal && normal.y > baseDiagonal) {
        lastDirection = Direction.downLeft;
      } else if (normal.x > normal.y) {
        lastDirection = Direction.left;
      } else {
        lastDirection = Direction.down;
      }
    } else if (velocity.x < 0 && velocity.y < 0) {
      if (normal.x > baseDiagonal && normal.y > baseDiagonal) {
        lastDirection = Direction.upLeft;
      } else if (normal.x > normal.y) {
        lastDirection = Direction.left;
      } else {
        lastDirection = Direction.up;
      }
    }
  }

  void _requestUpdatePriority() {
    if (hasGameRef) {
      (gameRef as BonfireGame).requestUpdatePriority();
    }
  }

  void _updatePosition(double dt) {
    onApplyDisplacement(dt);
    if (_moveTheMin()) {
      if (lastDirection.isDownSide || lastDirection.isUpSide) {
        _requestUpdatePriority();
      }
      onMove(_lastSpeed, displacement, lastDirection, velocityRadAngle);
    }
  }

  bool _moveTheMin() {
    return displacement.x.abs() > minDisplacementToConsiderMove ||
        displacement.y.abs() > minDisplacementToConsiderMove;
  }

  bool isStopped() {
    return velocity.x.abs() < 0.01 && velocity.y.abs() < 0.01;
  }

  // Move to position. return true whether move.
  bool moveToPosition(
    Vector2 position, {
    double? speed,
    bool useCenter = true,
  }) {
    double diagonalSpeed = (speed ?? this.speed) * diaginalReduction;
    double dtSpeed = (speed ?? this.speed) * dtUpdate * 1.1;
    double dtDiagonalSpeed = diagonalSpeed * dtUpdate * 1.1;
    final rect = rectCollision;
    final compCenter = rect.centerVector2;
    final compPosition = rect.positionVector2;

    double diffX = position.x - (useCenter ? compCenter : compPosition).x;
    double diffY = position.y - (useCenter ? compCenter : compPosition).y;

    if (diffX.abs() < dtSpeed && diffY.abs() < dtSpeed) {
      return false;
    } else {
      if (diffX.abs() > dtDiagonalSpeed && diffY.abs() > dtDiagonalSpeed) {
        final minToMOve = dtDiagonalSpeed * 2;
        final xOnce = diffX.abs() / dtUpdate;
        final yOnce = diffY.abs() / dtUpdate;
        if (diffX > 0 && diffY > 0) {
          if (diffX.abs() < minToMOve) {
            moveRightOnce(speed: xOnce);
          } else if (diffY.abs() < minToMOve) {
            moveDownOnce(speed: yOnce);
          } else {
            moveDownRight(speed: speed);
          }
          return true;
        } else if (diffX < 0 && diffY > 0) {
          if (diffX.abs() < minToMOve) {
            moveLeftOnce(speed: xOnce);
          } else if (diffY.abs() < minToMOve) {
            moveDownOnce(speed: yOnce);
          } else {
            moveDownLeft(speed: speed);
          }
          return true;
        } else if (diffX > 0 && diffY < 0) {
          if (diffX.abs() < minToMOve) {
            moveRightOnce(speed: xOnce);
          } else if (diffY.abs() < minToMOve) {
            moveUpOnce(speed: yOnce);
          } else {
            moveUpRight(speed: speed);
          }
          return true;
        } else if (diffX < 0 && diffY < 0) {
          if (diffX.abs() < dtSpeed) {
            moveLeftOnce(speed: xOnce);
          } else if (diffY.abs() < dtSpeed) {
            moveUpOnce(speed: yOnce);
          } else {
            moveUpLeft(speed: speed);
          }
          return true;
        }
      } else if (diffX.abs() > dtSpeed) {
        if (diffX > 0) {
          moveRight(speed: speed);
          return true;
        } else if (diffX < 0) {
          moveLeft(speed: speed);
          return true;
        }
      } else if (diffY.abs() > dtSpeed) {
        if (diffY > 0) {
          moveDown(speed: speed);
          return true;
        } else if (diffY < 0) {
          moveUp(speed: speed);
          return true;
        }
      } else {
        translate(Vector2(diffX, diffY));
        return true;
      }
    }
    return false;
  }

  bool canMove(
    Direction direction, {
    double? displacement,
    List<ShapeHitbox>? ignoreHitboxes,
  }) {
    double maxDistance = displacement ?? (speed * (dtUpdate * 2));

    switch (direction) {
      case Direction.right:
      case Direction.left:
      case Direction.up:
      case Direction.down:
        if (_checkRaycastDirection(
          direction,
          maxDistance,
          ignoreHitboxes: ignoreHitboxes,
        )) {
          return false;
        }
        break;
      case Direction.upLeft:
        if (_checkRaycastDirection(
          Direction.left,
          maxDistance,
          ignoreHitboxes: ignoreHitboxes,
        )) {
          return false;
        } else if (_checkRaycastDirection(
          Direction.up,
          maxDistance,
          ignoreHitboxes: ignoreHitboxes,
        )) {
          return false;
        }
        break;
      case Direction.upRight:
        if (_checkRaycastDirection(
          Direction.right,
          maxDistance,
          ignoreHitboxes: ignoreHitboxes,
        )) {
          return false;
        } else if (_checkRaycastDirection(
          Direction.up,
          maxDistance,
          ignoreHitboxes: ignoreHitboxes,
        )) {
          return false;
        }
        break;
      case Direction.downLeft:
        if (_checkRaycastDirection(
          Direction.left,
          maxDistance,
          ignoreHitboxes: ignoreHitboxes,
        )) {
          return false;
        } else if (_checkRaycastDirection(
          Direction.down,
          maxDistance,
          ignoreHitboxes: ignoreHitboxes,
        )) {
          return false;
        }
        break;
      case Direction.downRight:
        if (_checkRaycastDirection(
          Direction.right,
          maxDistance,
          ignoreHitboxes: ignoreHitboxes,
        )) {
          return false;
        } else if (_checkRaycastDirection(
          Direction.down,
          maxDistance,
          ignoreHitboxes: ignoreHitboxes,
        )) {
          return false;
        }
        break;
    }

    return true;
  }

  bool _checkRaycastDirection(
    Direction direction,
    double maxDistance, {
    List<ShapeHitbox>? ignoreHitboxes,
  }) {
    double distance = maxDistance;
    final centerComp = rectCollision.center.toVector2();
    Vector2 origin1 = centerComp;
    Vector2 origin3 = centerComp;
    final size = rectCollision.sizeVector2;
    final vetorDirection = direction.toVector2();

    switch (direction) {
      case Direction.right:
      case Direction.left:
        double halfY = (size.y / 2);
        double halfX = (size.y / 2);
        origin1 = origin1.translated(0, -halfY);
        origin3 = origin3.translated(0, halfY);
        distance += halfX;
        break;
      case Direction.up:
      case Direction.down:
        double halfX = (size.x / 2);
        double halfY = (size.y / 2);
        origin1 = origin1.translated(-halfX, 0);
        origin3 = origin3.translated(halfX, 0);
        distance += halfY;
        break;
      case Direction.upLeft:
      case Direction.upRight:
      case Direction.downLeft:
      case Direction.downRight:
    }
    bool check1 = raycast(
          vetorDirection,
          maxDistance: distance,
          origin: origin1,
          ignoreHitboxes: ignoreHitboxes,
        ) !=
        null;
    bool check2 = raycast(
          vetorDirection,
          maxDistance: distance,
          ignoreHitboxes: ignoreHitboxes,
        ) !=
        null;
    bool check3 = raycast(
          vetorDirection,
          maxDistance: distance,
          origin: origin3,
          ignoreHitboxes: ignoreHitboxes,
        ) !=
        null;
    return check1 || check2 || check3;
  }
}
