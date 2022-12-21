import 'dart:ui';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding movements
mixin Movement on GameComponent {
  // ignore: constant_identifier_names
  static const REDUCTION_SPEED_DIAGONAL = 0.7;

  bool isIdle = true;
  double dtUpdate = 0;
  double speed = 100;
  Direction lastDirection = Direction.right;
  Direction lastDirectionHorizontal = Direction.right;

  /// You can override this method to listen the movement of this component
  void onMove(
    double speed,
    Direction direction,
    double angle,
  ) {}

  /// Move player to Up
  bool moveUp(double speed, {bool notifyOnMove = true}) {
    double innerSpeed = speed * dtUpdate;
    Vector2 displacement = position.translate(0, (innerSpeed * -1));

    if (_isCollision(displacement)) {
      if (notifyOnMove) {
        onMove(
          0,
          Direction.up,
          BonfireUtil.getAngleFromDirection(Direction.up),
        );
      }
      return false;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.up;
    if (notifyOnMove) {
      onMove(
        speed,
        lastDirection,
        BonfireUtil.getAngleFromDirection(lastDirection),
      );
    }
    _requestUpdatePriority();
    return true;
  }

  /// Move player to Down
  bool moveDown(double speed, {bool notifyOnMove = true}) {
    double innerSpeed = speed * dtUpdate;
    Vector2 displacement = position.translate(0, innerSpeed);

    if (_isCollision(displacement)) {
      if (notifyOnMove) {
        onMove(
          0,
          Direction.down,
          BonfireUtil.getAngleFromDirection(Direction.down),
        );
      }
      return false;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.down;
    if (notifyOnMove) {
      onMove(
        speed,
        lastDirection,
        BonfireUtil.getAngleFromDirection(lastDirection),
      );
    }
    _requestUpdatePriority();
    return true;
  }

  /// Move player to Left
  bool moveLeft(double speed, {bool notifyOnMove = true}) {
    double innerSpeed = speed * dtUpdate;
    Vector2 displacement = position.translate((innerSpeed * -1), 0);

    if (_isCollision(displacement)) {
      if (notifyOnMove) {
        onMove(
          0,
          Direction.left,
          BonfireUtil.getAngleFromDirection(Direction.left),
        );
      }

      return false;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.left;
    lastDirectionHorizontal = Direction.left;
    if (notifyOnMove) {
      onMove(
        speed,
        lastDirection,
        BonfireUtil.getAngleFromDirection(lastDirection),
      );
    }
    return true;
  }

  /// Move player to Right
  bool moveRight(double speed, {bool notifyOnMove = true}) {
    double innerSpeed = speed * dtUpdate;
    Vector2 displacement = position.translate(innerSpeed, 0);

    if (_isCollision(displacement)) {
      if (notifyOnMove) {
        onMove(
          0,
          Direction.right,
          BonfireUtil.getAngleFromDirection(Direction.right),
        );
      }
      return false;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.right;
    lastDirectionHorizontal = Direction.right;
    if (notifyOnMove) {
      onMove(
        speed,
        lastDirection,
        BonfireUtil.getAngleFromDirection(lastDirection),
      );
    }
    return true;
  }

  /// Move player to Up and Right
  bool moveUpRight(double speedX, double speedY) {
    bool successRight = moveRight(
      speedX * REDUCTION_SPEED_DIAGONAL,
      notifyOnMove: false,
    );
    bool successUp = moveUp(
      speedY * REDUCTION_SPEED_DIAGONAL,
      notifyOnMove: false,
    );
    if (successRight && successUp) {
      lastDirection = Direction.upRight;
    }
    if (successRight | successUp) {
      onMove(
        speed,
        lastDirection,
        BonfireUtil.getAngleFromDirection(lastDirection),
      );
      return true;
    } else {
      onMove(
        0,
        Direction.upRight,
        BonfireUtil.getAngleFromDirection(Direction.upRight),
      );
      return false;
    }
  }

  /// Move player to Up and Left
  bool moveUpLeft(
    double speedX,
    double speedY,
  ) {
    bool successLeft = moveLeft(
      speedX * REDUCTION_SPEED_DIAGONAL,
      notifyOnMove: false,
    );
    bool successUp = moveUp(
      speedY * REDUCTION_SPEED_DIAGONAL,
      notifyOnMove: false,
    );
    if (successLeft && successUp) {
      lastDirection = Direction.upLeft;
    }

    if (successLeft | successUp) {
      onMove(
        speed,
        lastDirection,
        BonfireUtil.getAngleFromDirection(lastDirection),
      );
      return true;
    } else {
      onMove(
        0,
        Direction.upLeft,
        BonfireUtil.getAngleFromDirection(Direction.upLeft),
      );
      return false;
    }
  }

  /// Move player to Down and Left
  bool moveDownLeft(double speedX, double speedY) {
    bool successLeft = moveLeft(
      speedX * REDUCTION_SPEED_DIAGONAL,
      notifyOnMove: false,
    );
    bool successDown = moveDown(
      speedY * REDUCTION_SPEED_DIAGONAL,
      notifyOnMove: false,
    );

    if (successLeft && successDown) {
      lastDirection = Direction.downLeft;
    }

    if (successLeft | successDown) {
      onMove(
        speed,
        lastDirection,
        BonfireUtil.getAngleFromDirection(lastDirection),
      );
      return true;
    } else {
      onMove(
        0,
        Direction.downLeft,
        BonfireUtil.getAngleFromDirection(Direction.downLeft),
      );
      return false;
    }
  }

  /// Move player to Down and Right
  bool moveDownRight(double speedX, double speedY) {
    bool successRight = moveRight(
      speedX * REDUCTION_SPEED_DIAGONAL,
      notifyOnMove: false,
    );
    bool successDown = moveDown(
      speedY * REDUCTION_SPEED_DIAGONAL,
      notifyOnMove: false,
    );

    if (successRight && successDown) {
      lastDirection = Direction.downRight;
    }

    if (successRight | successDown) {
      onMove(
        speed,
        lastDirection,
        BonfireUtil.getAngleFromDirection(lastDirection),
      );
      return true;
    } else {
      onMove(
        0,
        Direction.downRight,
        BonfireUtil.getAngleFromDirection(Direction.downRight),
      );
      return false;
    }
  }

  bool moveByVector(Vector2 speed) {
    double innerSpeedX = speed.x * dtUpdate;
    double innerSpeedY = speed.y * dtUpdate;
    Vector2 displacement = position.translate(innerSpeedX, innerSpeedY);

    if (_isCollision(displacement)) {
      return false;
    }

    isIdle = false;
    position = displacement;
    return true;
  }

  /// Move Player to direction by radAngle
  bool moveFromAngle(double speed, double angle) {
    final rect = toRect();
    final center = rect.center.toVector2();
    Vector2 diffBase = BonfireUtil.diffMovePointByAngle(
      center,
      speed * dtUpdate,
      angle,
    );

    Offset newDiffBase = diffBase.toOffset();

    Rect newPosition = rect.shift(newDiffBase);

    _updateDirectionBuAngle(angle);

    if (_isCollision(newPosition.positionVector2)) {
      onMove(0, lastDirection, angle);
      return false;
    }

    isIdle = false;
    position = newPosition.positionVector2;
    onMove(speed, lastDirection, angle);
    return true;
  }

  /// Move to direction by radAngle with dodge obstacles
  bool moveFromAngleDodgeObstacles(
    double speed,
    double angle,
  ) {
    isIdle = false;
    double innerSpeed = (speed * dtUpdate);

    Vector2 diffBase = BonfireUtil.diffMovePointByAngle(
      center,
      innerSpeed,
      angle,
    );

    var collisionX = _verifyTranslateCollision(diffBase.x, 0);

    var collisionY = _verifyTranslateCollision(0, diffBase.y);

    Vector2 newDiffBase = diffBase;

    if (collisionX) {
      newDiffBase = Vector2(0, newDiffBase.y);
    }
    if (collisionY) {
      newDiffBase = Vector2(newDiffBase.x, 0);
    }

    if (collisionX && newDiffBase.y != 0) {
      double speedY = innerSpeed;
      if (newDiffBase.y < 0) {
        speedY *= -1;
      }
      final collisionY = _verifyTranslateCollision(
        0,
        speedY,
      );

      if (!collisionY) newDiffBase = Vector2(0, speedY);
    }

    if (collisionY && newDiffBase.x != 0) {
      double speedX = innerSpeed;
      if (newDiffBase.x < 0) {
        speedX *= -1;
      }
      final collisionX = _verifyTranslateCollision(
        speedX,
        0,
      );
      if (!collisionX) newDiffBase = Vector2(speedX, 0);
    }

    _updateDirectionBuAngle(angle);

    if (newDiffBase == Vector2.zero()) {
      onMove(0, lastDirection, angle);
      return false;
    }
    position.add(newDiffBase);
    onMove(speed, lastDirection, angle);
    return true;
  }

  /// Check if performing a certain translate on the enemy collision occurs
  bool _verifyTranslateCollision(
    double translateX,
    double translateY,
  ) {
    if (isObjectCollision()) {
      return (this as ObjectCollision)
          .isCollision(
            displacement: position.translate(
              translateX,
              translateY,
            ),
          )
          .isNotEmpty;
    } else {
      return false;
    }
  }

  void idle() {
    isIdle = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    dtUpdate = dt;
  }

  bool _isCollision(Vector2 displacement) {
    if (isObjectCollision()) {
      (this as ObjectCollision).setCollisionOnlyVisibleScreen(isVisible);
      return (this as ObjectCollision)
          .isCollision(
            displacement: displacement,
          )
          .isNotEmpty;
    }
    return false;
  }

  bool moveFromDirection(
    Direction direction, {
    Vector2? speedVector,
    bool enabledDiagonal = true,
  }) {
    double speedX = speedVector?.x ?? speed;
    double speedY = speedVector?.y ?? speed;
    switch (direction) {
      case Direction.left:
        return moveLeft(speedX);
      case Direction.right:
        return moveRight(speedX);
      case Direction.up:
        return moveUp(speedY);
      case Direction.down:
        return moveDown(speedY);
      case Direction.upLeft:
        if (enabledDiagonal) {
          return moveUpLeft(speedX, speedY);
        } else {
          return moveRight(speed);
        }

      case Direction.upRight:
        if (enabledDiagonal) {
          return moveUpRight(speedX, speedY);
        } else {
          return moveRight(speed);
        }

      case Direction.downLeft:
        if (enabledDiagonal) {
          return moveDownLeft(speedX, speedY);
        } else {
          return moveLeft(speed);
        }

      case Direction.downRight:
        if (enabledDiagonal) {
          return moveDownRight(speedX, speedY);
        } else {
          return moveRight(speed);
        }
    }
  }

  void _updateDirectionBuAngle(double angle) {
    lastDirection = BonfireUtil.getDirectionFromAngle(angle);

    if (lastDirection == Direction.right || lastDirection == Direction.left) {
      lastDirectionHorizontal = lastDirection;
    }
  }

  void _requestUpdatePriority() {
    if (hasGameRef) {
      (gameRef as BonfireGame).requestUpdatePriority();
    }
  }
}
