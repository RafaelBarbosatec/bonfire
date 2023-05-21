import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/mixins/movement.dart';
import 'package:bonfire/util/extensions/extensions.dart';

extension MovementExtensions on Movement {
  /// This method move this component to target
  /// Need use Movement mixin.
  /// Method that bo used in [update] method.
  /// return true if moved.
  void followComponent(
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

    if (translateX > 0 && translateY > 0) {
      moveDownRight();
    } else if (translateX < 0 && translateY < 0) {
       moveUpLeft();
    } else if (translateX > 0 && translateY < 0) {
       moveUpRight();
    } else if (translateX < 0 && translateY > 0) {
      moveDownLeft();
    } else {
      if (translateX > 0) {
        moveRight();
      } else if (translateX < 0) {
        moveLeft();
      }
      if (translateY > 0) {
        moveDown();
      } else if (translateY < 0) {
       moveUp();
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
    if (runOnlyVisibleInScreen && !isVisible) return;
    double distance = (minDistanceFromPlayer ?? radiusVision);

    Rect rectTarget = target.rectConsideringCollision;
    double centerXTarget = rectTarget.center.dx;
    double centerYTarget = rectTarget.center.dy;

    double translateX = 0;
    double translateY = 0;

    double speed = this.speed * dtUpdate;

    Rect rectToMove = rectConsideringCollision;

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
      stopMove();
      positioned(target);
    }

  
    if (translateX > 0 && translateY > 0) {
      moveDownRight();
    } else if (translateX < 0 && translateY < 0) {
       moveUpLeft();
    } else if (translateX > 0 && translateY < 0) {
       moveUpRight();
    } else if (translateX < 0 && translateY > 0) {
     moveDownLeft();
    } else {
      if (translateX > 0) {
        moveRight();
      } else if (translateX < 0) {
        moveLeft();
      }
      if (translateY > 0) {
        moveDown();
      } else if (translateY < 0) {
        moveUp();
      }
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
}
