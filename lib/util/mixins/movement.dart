import 'dart:math';
import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:bonfire/util/functions.dart';
import 'package:flame/components.dart';

/// Mixin responsible for adding movements
mixin Movement on GameComponent {
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
        onMove(0, Direction.up, getAngleByDirectional(Direction.up));
      }
      return false;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.up;
    if (notifyOnMove) {
      onMove(speed, lastDirection, getAngleByDirectional(lastDirection));
    }
    return true;
  }

  /// Move player to Down
  bool moveDown(double speed, {bool notifyOnMove = true}) {
    double innerSpeed = speed * dtUpdate;
    Vector2 displacement = position.translate(0, innerSpeed);

    if (_isCollision(displacement)) {
      if (notifyOnMove) {
        onMove(0, Direction.down, getAngleByDirectional(Direction.down));
      }
      return false;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.down;
    if (notifyOnMove) {
      onMove(speed, lastDirection, getAngleByDirectional(lastDirection));
    }
    return true;
  }

  /// Move player to Left
  bool moveLeft(double speed, {bool notifyOnMove = true}) {
    double innerSpeed = speed * dtUpdate;
    Vector2 displacement = position.translate((innerSpeed * -1), 0);

    if (_isCollision(displacement)) {
      if (notifyOnMove) {
        onMove(0, Direction.left, getAngleByDirectional(Direction.left));
      }

      return false;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.left;
    lastDirectionHorizontal = Direction.left;
    if (notifyOnMove) {
      onMove(speed, lastDirection, getAngleByDirectional(lastDirection));
    }
    return true;
  }

  /// Move player to Right
  bool moveRight(double speed, {bool notifyOnMove = true}) {
    double innerSpeed = speed * dtUpdate;
    Vector2 displacement = position.translate(innerSpeed, 0);

    if (_isCollision(displacement)) {
      if (notifyOnMove) {
        onMove(0, Direction.right, getAngleByDirectional(Direction.right));
      }
      return false;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.right;
    lastDirectionHorizontal = Direction.right;
    if (notifyOnMove) {
      onMove(speed, lastDirection, getAngleByDirectional(lastDirection));
    }
    return true;
  }

  /// Move player to Up and Right
  bool moveUpRight(double speedX, double speedY) {
    bool successRight = moveRight(speedX, notifyOnMove: false);
    bool successUp = moveUp(speedY, notifyOnMove: false);
    if (successRight && successUp) {
      lastDirection = Direction.upRight;
    }
    if (successRight | successUp) {
      onMove(speed, lastDirection, getAngleByDirectional(lastDirection));
      return true;
    } else {
      onMove(0, Direction.upRight, getAngleByDirectional(Direction.upRight));
      return false;
    }
  }

  /// Move player to Up and Left
  bool moveUpLeft(
    double speedX,
    double speedY,
  ) {
    bool successLeft = moveLeft(speedX, notifyOnMove: false);
    bool successUp = moveUp(speedY, notifyOnMove: false);
    if (successLeft && successUp) {
      lastDirection = Direction.upLeft;
    }

    if (successLeft | successUp) {
      onMove(speed, lastDirection, getAngleByDirectional(lastDirection));
      return true;
    } else {
      onMove(0, Direction.upLeft, getAngleByDirectional(Direction.upLeft));
      return false;
    }
  }

  /// Move player to Down and Left
  bool moveDownLeft(double speedX, double speedY) {
    bool successLeft = moveLeft(speedX, notifyOnMove: false);
    bool successDown = moveDown(speedY, notifyOnMove: false);

    if (successLeft && successDown) {
      lastDirection = Direction.downLeft;
    }

    if (successLeft | successDown) {
      onMove(speed, lastDirection, getAngleByDirectional(lastDirection));
      return true;
    } else {
      onMove(0, Direction.downLeft, getAngleByDirectional(Direction.downLeft));
      return false;
    }
  }

  /// Move player to Down and Right
  bool moveDownRight(double speedX, double speedY) {
    bool successRight = moveRight(speedX, notifyOnMove: false);
    bool successDown = moveDown(speedY, notifyOnMove: false);

    if (successRight && successDown) {
      lastDirection = Direction.downRight;
    }

    if (successRight | successDown) {
      onMove(speed, lastDirection, getAngleByDirectional(lastDirection));
      return true;
    } else {
      onMove(
          0, Direction.downRight, getAngleByDirectional(Direction.downRight));
      return false;
    }
  }

  /// Move Player to direction by radAngle
  bool moveFromAngle(double speed, double angle) {
    double nextX = (speed * dtUpdate) * cos(angle);
    double nextY = (speed * dtUpdate) * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    final rect = toRect();
    Offset diffBase = Offset(
          rect.center.dx + nextPoint.dx,
          rect.center.dy + nextPoint.dy,
        ) -
        rect.center;

    Offset newDiffBase = diffBase;

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
    double nextX = innerSpeed * cos(angle);
    double nextY = innerSpeed * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Vector2 diffBase =
        Vector2(this.center.x + nextPoint.dx, this.center.y + nextPoint.dy) -
            this.center;

    var collisionX = _verifyTranslateCollision(
      diffBase.x,
      0,
    );
    var collisionY = _verifyTranslateCollision(
      0,
      diffBase.y,
    );

    Vector2 newDiffBase = diffBase;

    if (collisionX) {
      newDiffBase = Vector2(0, newDiffBase.y);
    }
    if (collisionY) {
      newDiffBase = Vector2(newDiffBase.x, 0);
    }

    if (collisionX && !collisionY && newDiffBase.y != 0) {
      var collisionY = _verifyTranslateCollision(
        0,
        innerSpeed,
      );
      if (!collisionY) newDiffBase = Vector2(0, innerSpeed);
    }

    if (collisionY && !collisionX && newDiffBase.x != 0) {
      var collisionX = _verifyTranslateCollision(
        innerSpeed,
        0,
      );
      if (!collisionX) newDiffBase = Vector2(innerSpeed, 0);
    }

    _updateDirectionBuAngle(angle);

    if (newDiffBase == Vector2.zero()) {
      onMove(0, lastDirection, angle);
      return false;
    }
    this.position.add(newDiffBase);
    onMove(speed, lastDirection, angle);
    return true;
  }

  /// Check if performing a certain translate on the enemy collision occurs
  bool _verifyTranslateCollision(
    double translateX,
    double translateY,
  ) {
    if (this.isObjectCollision()) {
      return (this as ObjectCollision)
          .isCollision(
            displacement: this.position.translate(
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
    if (this.isObjectCollision()) {
      (this as ObjectCollision).setCollisionOnlyVisibleScreen(this.isVisible);
      return (this as ObjectCollision)
          .isCollision(
            displacement: displacement,
          )
          .isNotEmpty;
    }
    return false;
  }

  bool moveFromDirection(Direction direction, {bool enabledDiagonal = true}) {
    switch (direction) {
      case Direction.left:
        return moveLeft(speed);
      case Direction.right:
        return moveRight(speed);
      case Direction.up:
        return moveUp(speed);
      case Direction.down:
        return moveDown(speed);
      case Direction.upLeft:
        if (enabledDiagonal) {
          return moveUpLeft(speed * REDUCTION_SPEED_DIAGONAL,
              speed * REDUCTION_SPEED_DIAGONAL);
        } else {
          return moveRight(speed);
        }

      case Direction.upRight:
        if (enabledDiagonal) {
          return moveUpRight(speed * REDUCTION_SPEED_DIAGONAL,
              speed * REDUCTION_SPEED_DIAGONAL);
        } else {
          return moveRight(speed);
        }

      case Direction.downLeft:
        if (enabledDiagonal) {
          return moveDownLeft(speed * REDUCTION_SPEED_DIAGONAL,
              speed * REDUCTION_SPEED_DIAGONAL);
        } else {
          return moveLeft(speed);
        }

      case Direction.downRight:
        if (enabledDiagonal) {
          return moveDownRight(speed * REDUCTION_SPEED_DIAGONAL,
              speed * REDUCTION_SPEED_DIAGONAL);
        } else {
          return moveRight(speed);
        }
    }
  }

  void _updateDirectionBuAngle(double angle) {
    lastDirection = getDirectionByAngle(angle);

    if (lastDirection == Direction.right || lastDirection == Direction.left) {
      lastDirectionHorizontal = lastDirection;
    }
  }
}
