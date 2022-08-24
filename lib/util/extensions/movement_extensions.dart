import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:bonfire/util/mixins/movement.dart';

extension MovementExtensions on Movement {
  /// This method move this component to target
  /// Need use Movement mixin.
  /// Method that bo used in [update] method.
  /// return true if moved.
  bool followComponent(
    GameComponent target,
    double dt, {
    required Function(GameComponent) closeComponent,
    double margin = 10,
  }) {
    final comp = target.rectConsideringCollision;
    double centerXPlayer = comp.center.dx;
    double centerYPlayer = comp.center.dy;

    double translateX = 0;
    double translateY = 0;
    double speed = this.speed * dt;

    Rect rectToMove = rectConsideringCollision;

    translateX = rectToMove.center.dx > centerXPlayer ? (-1 * speed) : speed;

    translateX = _adjustTranslate(
      translateX,
      rectToMove.center.dx,
      centerXPlayer,
    );
    translateY = rectToMove.center.dy > centerYPlayer ? (-1 * speed) : speed;
    translateY = _adjustTranslate(
      translateY,
      rectToMove.center.dy,
      centerYPlayer,
    );

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
      return false;
    }

    translateX /= dt;
    translateY /= dt;

    bool moved = false;

    if (translateX > 0 && translateY > 0) {
      moved = moveDownRight(translateX, translateY);
    } else if (translateX < 0 && translateY < 0) {
      moved = moveUpLeft(translateX.abs(), translateY.abs());
    } else if (translateX > 0 && translateY < 0) {
      moved = moveUpRight(translateX, translateY.abs());
    } else if (translateX < 0 && translateY > 0) {
      moved = moveDownLeft(translateX.abs(), translateY);
    } else {
      if (translateX > 0) {
        moved = moveRight(translateX);
      } else if (translateX < 0) {
        moved = moveLeft(translateX.abs());
      }
      if (translateY > 0) {
        moved = moveDown(translateY);
      } else if (translateY < 0) {
        moved = moveUp(translateY.abs());
      }
    }

    if (!moved) {
      this.idle();
      return false;
    }

    return true;
  }

  /// Checks whether the component is within range. If so, position yourself and keep your distance.
  /// Method that bo used in [update] method.
  void positionsItselfAndKeepDistance(
    GameComponent target, {
    required Function(GameComponent) positioned,
    double radiusVision = 32,
    double? minDistanceFromPlayer,
    bool runOnlyVisibleInScreen = true,
    VoidCallback? canNotMove,
  }) {
    if (runOnlyVisibleInScreen && !this.isVisible) return;
    double distance = (minDistanceFromPlayer ?? radiusVision);

    Rect rectTarget = target.rectConsideringCollision;
    double centerXPlayer = rectTarget.center.dx;
    double centerYPlayer = rectTarget.center.dy;

    double translateX = 0;
    double translateY = 0;

    double speed = this.speed * this.dtUpdate;

    Rect rectToMove = rectConsideringCollision;

    translateX = rectToMove.center.dx > centerXPlayer ? (-1 * speed) : speed;
    translateX = _adjustTranslate(
      translateX,
      rectToMove.center.dx,
      centerXPlayer,
    );

    translateY = rectToMove.center.dy > centerYPlayer ? (-1 * speed) : speed;
    translateY = _adjustTranslate(
      translateY,
      rectToMove.center.dy,
      centerYPlayer,
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

    bool moved = false;
    if (translateX > 0 && translateY > 0) {
      moved = moveDownRight(translateX, translateY);
    } else if (translateX < 0 && translateY < 0) {
      moved = moveUpLeft(translateX.abs(), translateY.abs());
    } else if (translateX > 0 && translateY < 0) {
      moved = moveUpRight(translateX, translateY.abs());
    } else if (translateX < 0 && translateY > 0) {
      moved = moveDownLeft(translateX.abs(), translateY);
    } else {
      if (translateX > 0) {
        moved = moveRight(translateX);
      } else {
        moved = moveLeft(translateX.abs());
      }
      if (translateY > 0) {
        moved = moveDown(translateY);
      } else {
        moved = moveUp(translateY.abs());
      }
    }

    if (!moved) {
      this.idle();
      canNotMove?.call();
    }
  }

  double _adjustTranslate(
    double translate,
    double centerEnemy,
    double centerPlayer,
  ) {
    double diff = centerPlayer - centerEnemy;

    if (translate.abs() > diff.abs()) {
      return diff;
    } else {
      return translate;
    }
  }
}
