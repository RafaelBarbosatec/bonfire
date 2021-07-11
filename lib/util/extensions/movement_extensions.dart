import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/mixins/movement.dart';

import '../functions.dart';
import '../vector2rect.dart';

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
    if (!(this is Movement)) {
      print('$this need use Movement mixin.');
      return;
    }

    double translateX = 0;
    double translateY = 0;
    double speed = this.speed * dt;

    Vector2Rect rectToMove = this.isObjectCollision()
        ? (this as ObjectCollision).rectCollision
        : position;

    translateX =
        rectToMove.rect.center.dx > centerXPlayer ? (-1 * speed) : speed;

    translateX = _adjustTranslate(
      translateX,
      rectToMove.rect.center.dx,
      centerXPlayer,
      speed,
    );
    translateY =
        rectToMove.rect.center.dy > centerYPlayer ? (-1 * speed) : speed;
    translateY = _adjustTranslate(
      translateY,
      rectToMove.rect.center.dy,
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

    if (rectToMove.rect.overlaps(rectPlayerCollision)) {
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
