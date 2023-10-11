import 'dart:math';

import 'package:bonfire/bonfire.dart';

extension MovementExtensions on Movement {
  /// This method move this component to target
  /// Need use Movement mixin.
  /// Method that bo used in [update] method.
  /// return true if moved.
  bool moveTowardsTarget<T extends GameComponent>({
    required T target,
    Function? close,
    double margin = 4,
  }) {
    double radAngle = getAngleFromTarget(target);

    Rect rectPlayerCollision = target.rectCollision.inflate(margin);

    if (rectCollision.overlaps(rectPlayerCollision)) {
      close?.call();
      stopMove();
      return false;
    }
    moveFromAngle(radAngle);
    return true;
  }

  bool keepDistance(GameComponent target, double minDistance) {
    if (!isVisible) return true;
    double distance = absoluteCenter.distanceTo(target.absoluteCenter);

    if (distance < minDistance) {
      var angle = getAngleFromTarget(target);
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
    if (runOnlyVisibleInScreen && !isVisible) return false;
    double distance = (minDistanceFromPlayer ?? radiusVision);

    Rect rectTarget = target.rectCollision;
    double centerXTarget = rectTarget.center.dx;
    double centerYTarget = rectTarget.center.dy;

    double translateX = 0;
    double translateY = 0;

    double speed = this.speed * dtUpdate;

    Rect rectToMove = rectCollision;

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

    double translateXPositive =
        (rectToMove.center.dx - rectTarget.center.dx).abs();

    double translateYPositive =
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
    double diff = centerPlayer - centerEnemy;
    double newTrasnlate = 0;
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
}
