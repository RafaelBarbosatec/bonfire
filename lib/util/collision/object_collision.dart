import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:flutter/material.dart';

mixin ObjectCollision {
  Collision collision = Collision();

  bool isCollision(Rect displacement, RPGGame game) {
    Rect rectCollision = _createRectCollision(displacement);

    var collisions = game.map
        .getCollisionsRendered()
        .where((i) => i.collision && i.position.overlaps(rectCollision))
        .toList();

    if (collisions.length > 0) {
      return true;
    }

    if (game.decorations != null) {
      var collisionsDecorations = game.decorations
          .where((i) =>
              !i.destroy() && i.collision && i.position.overlaps(rectCollision))
          .toList();

      if (collisionsDecorations.length > 0) {
        return true;
      }
    }

    return false;
  }

  bool isCollisionPositionInWorld(Rect displacement, RPGGame game) {
    Rect rectCollision = _createRectCollision(displacement);

    var collisions = game.map
        .getCollisionsRendered()
        .where((i) => i.collision && i.positionInWorld.overlaps(rectCollision))
        .toList();

    if (collisions.length > 0) {
      return true;
    }

    if (game.decorations != null) {
      var collisionsDecorations = game.decorations
          .where((i) =>
              !i.destroy() &&
              i.collision &&
              i.positionInWorld.overlaps(rectCollision))
          .toList();

      if (collisionsDecorations.length > 0) {
        return true;
      }
    }

    return false;
  }

  bool isCollisionTranslate(
      Rect position, double translateX, double translateY, RPGGame game) {
    var moveToCurrent = position.translate(translateX, translateY);
    return isCollision(moveToCurrent, game);
  }

  Rect _createRectCollision(Rect displacement) {
    double left =
        displacement.left + (displacement.width - collision.width) / 2;

    double top = 0.0;

    switch (collision.align) {
      case CollisionAlign.BOTTOM_CENTER:
        top = displacement.bottom - collision.height;
        break;
      case CollisionAlign.CENTER:
        top = displacement.top + (displacement.height - collision.height) / 2;
        break;
      case CollisionAlign.TOP_CENTER:
        top = displacement.top;
        break;
    }
    return Rect.fromLTWH(left, top, collision.width, collision.height);
  }

  void drawCollision(Canvas canvas, Rect currentPosition) {
    canvas.drawRect(
      _createRectCollision(currentPosition),
      new Paint()..color = Colors.lightGreenAccent.withOpacity(0.5),
    );
  }
}
