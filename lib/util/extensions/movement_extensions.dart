import 'dart:math';

import 'package:bonfire/bonfire.dart';

enum MovementAxis { horizontal, vertical, withoutDiagonal, all }

extension MovementExtensions on Movement {
  /// This method move this component to target
  /// Need use Movement mixin.
  /// Method that bo used in [update] method.
  /// return true if moved.
  bool moveTowardsTarget<T extends GameComponent>({
    required T target,
    void Function()? close,
    double margin = 4,
    MovementAxis movementAxis = MovementAxis.all,
  }) {
    final rectPlayerCollision = target.rectCollision.inflate(margin);

    if (rectCollision.overlaps(rectPlayerCollision)) {
      close?.call();
      stopMove();
      return false;
    }

    final radAngle = getAngleToTarget(target);
    var directionToMove = BonfireUtil.getDirectionFromAngle(
      radAngle,
    );
    final newDirectionToMove = _checkRestrictAxis(
      directionToMove,
      movementAxis,
    );
    if (newDirectionToMove != null) {
      directionToMove = newDirectionToMove;
    } else {
      stopMove();
      return false;
    }

    if (canMove(directionToMove, ignoreHitboxes: target.shapeHitboxes)) {
      if (directionToMove != lastDirection) {
        setZeroVelocity();
      }
      moveFromDirection(directionToMove);
      return true;
    } else {
      switch (directionToMove) {
        case Direction.right:
        case Direction.left:
        case Direction.up:
        case Direction.down:
          break;
        case Direction.upLeft:
          if (canMove(Direction.left)) {
            moveLeft();
            return true;
          } else if (canMove(Direction.up)) {
            moveUp();
            return true;
          }
          break;
        case Direction.upRight:
          if (canMove(Direction.right)) {
            moveRight();
            return true;
          } else if (canMove(Direction.up)) {
            moveUp();
            return true;
          }
          break;
        case Direction.downLeft:
          if (canMove(Direction.left)) {
            moveLeft();
            return true;
          } else if (canMove(Direction.down)) {
            moveDown();
            return true;
          }
          break;
        case Direction.downRight:
          if (canMove(Direction.right)) {
            moveRight();
            return true;
          } else if (canMove(Direction.down)) {
            moveDown();
            return true;
          }
          break;
      }
      stopMove();
      return false;
    }
  }

  bool keepDistance(GameComponent target, double minDistance) {
    if (!isVisible) {
      return true;
    }
    final distance = rectCollision.centerVector2.distanceTo(
      target.rectCollision.centerVector2,
    );

    if (distance < minDistance) {
      final angle = getAngleToTarget(target);
      moveFromAngle(angle + pi);
      return false;
    }
    return true;
  }

  /// Checks whether the component is within range. If so, position yourself and keep your distance.
  /// Method that bo used in [update] method.
  bool positionsItselfAndKeepDistance<T extends GameComponent>(
    T target, {
    Function(T)? positioned,
    double radiusVision = 32,
    double? minDistanceFromPlayer,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (runOnlyVisibleInScreen && !isVisible) {
      return false;
    }
    final distance = minDistanceFromPlayer ?? radiusVision;

    final rectTarget = target.rectCollision;
    final centerXTarget = rectTarget.center.dx;
    final centerYTarget = rectTarget.center.dy;

    var translateX = 0.0;
    var translateY = 0.0;

    final speed = this.speed * lastDt;

    final rectToMove = rectCollision;

    translateX = rectToMove.center.dx > centerXTarget ? (-1 * speed) : speed;
    translateX = _adjustTranslate(
      translateX,
      rectToMove.center.dx,
      centerXTarget,
    );

    translateY = rectToMove.center.dy > centerYTarget ? (-1 * speed) : speed;
    translateY = _adjustTranslate(
      translateY,
      rectToMove.center.dy,
      centerYTarget,
    );

    final translateXPositive =
        (rectToMove.center.dx - rectTarget.center.dx).abs();

    final translateYPositive =
        (rectToMove.center.dy - rectTarget.center.dy).abs();

    if (translateXPositive >= distance &&
        translateXPositive > translateYPositive) {
      translateX = 0;
    } else if (translateXPositive > translateYPositive) {
      translateX = translateX * -1;
    }

    if (translateYPositive >= distance &&
        translateXPositive < translateYPositive) {
      translateY = 0;
    } else if (translateXPositive < translateYPositive) {
      translateY = translateY * -1;
    }

    if (translateX.abs() < dtSpeed && translateY.abs() < dtSpeed) {
      stopMove();
      positioned?.call(target);
      return false;
    } else {
      _moveComp(translateX, translateY);
      return true;
    }
  }

  double _adjustTranslate(
    double translate,
    double centerEnemy,
    double centerPlayer,
  ) {
    final diff = centerPlayer - centerEnemy;
    var newTrasnlate = 0.0;
    if (translate.abs() > diff.abs()) {
      newTrasnlate = diff;
    } else {
      newTrasnlate = translate;
    }

    if (newTrasnlate.abs() < 0.1) {
      newTrasnlate = 0;
    }

    return newTrasnlate;
  }

  void _moveComp(double translateX, double translateY) {
    if (translateX > 0 && translateY > 0) {
      moveDownRight();
    } else if (translateX < 0 && translateY < 0) {
      moveUpLeft();
    } else if (translateX > 0 && translateY < 0) {
      moveUpRight();
    } else if (translateX < 0 && translateY > 0) {
      moveDownLeft();
    } else {
      if (translateX.abs() > dtSpeed) {
        if (translateX > 0) {
          moveRight();
        } else if (translateX < 0) {
          moveLeft();
        }
      } else if (translateX.abs() > dtSpeed / 2) {
        if (translateX > 0) {
          moveRight(speed: speed / 2);
        } else if (translateX < 0) {
          moveLeft(speed: speed / 2);
        }
      }
      if (translateY.abs() > dtSpeed) {
        if (translateY > 0) {
          moveDown();
        } else if (translateY < 0) {
          moveUp();
        }
      } else if (translateY.abs() > dtSpeed / 2) {
        if (translateY > 0) {
          moveDown(speed: speed / 2);
        } else if (translateY < 0) {
          moveUp(speed: speed / 2);
        }
      }
    }
  }

  Direction? _checkRestrictAxis(
    Direction directionToMove,
    MovementAxis moveAxis,
  ) {
    if (moveAxis == MovementAxis.all) {
      return directionToMove;
    }
    switch (directionToMove) {
      case Direction.upLeft:
        switch (moveAxis) {
          case MovementAxis.horizontal:
          case MovementAxis.withoutDiagonal:
            return Direction.left;
          case MovementAxis.vertical:
            return Direction.up;

          default:
        }
      case Direction.upRight:
        switch (moveAxis) {
          case MovementAxis.horizontal:
          case MovementAxis.withoutDiagonal:
            return Direction.right;
          case MovementAxis.vertical:
            return Direction.up;

          default:
        }
      case Direction.downLeft:
        switch (moveAxis) {
          case MovementAxis.horizontal:
          case MovementAxis.withoutDiagonal:
            return Direction.left;
          case MovementAxis.vertical:
            return Direction.down;

          default:
        }
      case Direction.downRight:
        switch (moveAxis) {
          case MovementAxis.horizontal:
          case MovementAxis.withoutDiagonal:
            return Direction.right;
          case MovementAxis.vertical:
            return Direction.down;
          default:
        }
      case Direction.left:
        if (moveAxis == MovementAxis.vertical) {
          return null;
        } else {
          return directionToMove;
        }
      case Direction.right:
        if (moveAxis == MovementAxis.vertical) {
          return null;
        } else {
          return directionToMove;
        }
      case Direction.up:
        if (moveAxis == MovementAxis.horizontal) {
          return null;
        } else {
          return directionToMove;
        }
      case Direction.down:
        if (moveAxis == MovementAxis.horizontal) {
          return null;
        } else {
          return directionToMove;
        }
    }
    return null;
  }
}
