import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/mixins/movement.dart';

import '../functions.dart';

extension MovementExtensions on Movement {
  /// This method move this component to target
  /// Need use Movement mixin.
  /// Method that bo used in [update] method.
  void followComponent(
    GameComponent target,
    double dt, {
    required Function(GameComponent) closeComponent,
    double margin = 10,
  }) {
    final comp = getRectAndCollision(target);
    double centerXPlayer = comp.center.dx;
    double centerYPlayer = comp.center.dy;

    double translateX = 0;
    double translateY = 0;
    double speed = this.speed * dt;

    Rect rectToMove = this.isObjectCollision()
        ? (this as ObjectCollision).rectCollision
        : toRect();

    translateX = rectToMove.center.dx > centerXPlayer ? (-1 * speed) : speed;

    translateX = _adjustTranslate(
      translateX,
      rectToMove.center.dx,
      centerXPlayer,
      speed,
    );
    translateY = rectToMove.center.dy > centerYPlayer ? (-1 * speed) : speed;
    translateY = _adjustTranslate(
      translateY,
      rectToMove.center.dy,
      centerYPlayer,
      speed,
    );

    if ((translateX < 0 && translateX > -0.1) ||
        (translateX > 0 && translateX < 0.1)) {
      translateX = 0;
    }

    if ((translateY < 0 && translateY > -0.1) ||
        (translateY > 0 && translateY < 0.1)) {
      translateY = 0;
    }

    Rect rectPlayerCollision = Rect.fromLTWH(
      comp.left - margin,
      comp.top - margin,
      comp.width + (margin * 2),
      comp.height + (margin * 2),
    );

    if (rectToMove.overlaps(rectPlayerCollision)) {
      closeComponent(target);
      if (!this.isIdle) {
        this.idle();
      }
      return;
    }

    translateX = translateX / dt;
    translateY = translateY / dt;

    if (translateX > 0 && translateY > 0) {
      this.moveDownRight(translateX, translateY);
    } else if (translateX < 0 && translateY < 0) {
      this.moveUpLeft(translateX.abs(), translateY.abs());
    } else if (translateX > 0 && translateY < 0) {
      this.moveUpRight(translateX, translateY.abs());
    } else if (translateX < 0 && translateY > 0) {
      this.moveDownLeft(translateX.abs(), translateY);
    } else {
      if (translateX > 0) {
        this.moveRight(translateX);
      } else if (translateX < 0) {
        this.moveLeft(translateX.abs());
      }
      if (translateY > 0) {
        this.moveDown(translateY);
      } else if (translateY < 0) {
        this.moveUp(translateY.abs());
      }
    }
  }

  /// Checks whether the component is within range. If so, position yourself and keep your distance.
  /// Method that bo used in [update] method.
  void positionsItselfAndKeepDistance(
    GameComponent target, {
    required Function(GameComponent) positioned,
    double radiusVision = 32,
    double? minDistanceFromPlayer,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (runOnlyVisibleInScreen && !this.isVisible) return;
    double distance = (minDistanceFromPlayer ?? radiusVision);

    Rect rectTarget = getRectAndCollision(target);
    double centerXPlayer = rectTarget.center.dx;
    double centerYPlayer = rectTarget.center.dy;

    double translateX = 0;
    double translateY = 0;

    double speed = this.speed * this.dtUpdate;

    Rect rectToMove = getRectAndCollision(this);

    translateX = rectToMove.center.dx > centerXPlayer ? (-1 * speed) : speed;
    translateX = _adjustTranslate(
      translateX,
      rectToMove.center.dx,
      centerXPlayer,
      speed,
    );

    translateY = rectToMove.center.dy > centerYPlayer ? (-1 * speed) : speed;
    translateY = _adjustTranslate(
      translateY,
      rectToMove.center.dy,
      centerYPlayer,
      speed,
    );

    if ((translateX < 0 && translateX > -0.1) ||
        (translateX > 0 && translateX < 0.1)) {
      translateX = 0;
    }

    if ((translateY < 0 && translateY > -0.1) ||
        (translateY > 0 && translateY < 0.1)) {
      translateY = 0;
    }

    double translateXPositive = rectToMove.center.dx - rectTarget.center.dx;
    translateXPositive =
        translateXPositive >= 0 ? translateXPositive : translateXPositive * -1;

    double translateYPositive = rectToMove.center.dy - rectTarget.center.dy;
    translateYPositive =
        translateYPositive >= 0 ? translateYPositive : translateYPositive * -1;

    if (translateXPositive >= distance &&
        translateXPositive > translateYPositive) {
      translateX = 0;
    } else if (translateXPositive > translateYPositive) {
      translateX = translateX * -1;
      positioned(target);
    }

    if (translateYPositive >= distance &&
        translateXPositive < translateYPositive) {
      translateY = 0;
    } else if (translateXPositive < translateYPositive) {
      translateY = translateY * -1;
      positioned(target);
    }

    if (translateX == 0 && translateY == 0) {
      if (!this.isIdle) {
        this.idle();
      }
      positioned(target);
      return;
    }

    translateX = translateX / this.dtUpdate;
    translateY = translateY / this.dtUpdate;

    if (translateX > 0 && translateY > 0) {
      moveDownRight(translateX, translateY);
    } else if (translateX < 0 && translateY < 0) {
      moveUpLeft(translateX.abs(), translateY.abs());
    } else if (translateX > 0 && translateY < 0) {
      moveUpRight(translateX, translateY.abs());
    } else if (translateX < 0 && translateY > 0) {
      moveDownLeft(translateX.abs(), translateY);
    } else {
      if (translateX > 0) {
        moveRight(translateX);
      } else {
        moveLeft(translateX.abs());
      }
      if (translateY > 0) {
        moveDown(translateY);
      } else {
        moveUp(translateY.abs());
      }
    }
  }

  double _adjustTranslate(
    double translate,
    double centerEnemy,
    double centerPlayer,
    double speed,
  ) {
    double innerTranslate = translate;
    if (innerTranslate > 0) {
      double diffX = centerPlayer - centerEnemy;
      if (diffX < speed) {
        innerTranslate = diffX;
      }
    } else if (innerTranslate < 0) {
      double diffX = centerPlayer - centerEnemy;
      if (diffX > (speed * -1)) {
        innerTranslate = diffX;
      }
    }

    return innerTranslate;
  }
}
