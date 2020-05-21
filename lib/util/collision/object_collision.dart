import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:flutter/material.dart';

mixin ObjectCollision {
  Collision collision = Collision();

  bool isCollision(Rect displacement, RPGGame game) {
    Rect rectCollision = getRectCollision(displacement);

    var collisions = game.map
        .getCollisionsRendered()
        .where((i) => i.collision && i.position.overlaps(rectCollision));

    if (collisions.length > 0) {
      return true;
    }

    if (game.decorations != null) {
      var collisionsDecorations = game.decorations.where((i) =>
          !i.destroy() &&
          i.collision != null &&
          i.rectCollision.overlaps(rectCollision));

      if (collisionsDecorations.length > 0) {
        return true;
      }
    }

    return false;
  }

  bool isCollisionPositionInWorld(Rect displacement, RPGGame game) {
    Rect rectCollision = getRectCollision(displacement);

    var collisions = game.map
        .getCollisionsRendered()
        .where((i) => i.collision && i.positionInWorld.overlaps(rectCollision));

    if (collisions.length > 0) {
      return true;
    }

    if (game.decorations != null) {
      var collisionsDecorations = game.decorations.where((i) =>
          !i.destroy() &&
          i.collision != null &&
          i.rectCollisionInWorld.overlaps(rectCollision));

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

  Rect getRectCollision(Rect displacement) {
    double left =
        displacement.left + (displacement.width - collision.width) / 2;

    double top =
        displacement.top + (displacement.height - collision.height) / 2;

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
      case CollisionAlign.LEFT_CENTER:
        left = displacement.left;
        break;
      case CollisionAlign.RIGHT_CENTER:
        left = displacement.right - collision.width;
        break;
      case CollisionAlign.TOP_LEFT:
        top = displacement.top;
        left = displacement.left;
        break;
      case CollisionAlign.TOP_RIGHT:
        top = displacement.top;
        left = displacement.right - collision.width;
        break;
      case CollisionAlign.BOTTOM_LEFT:
        top = displacement.bottom - collision.height;
        left = displacement.left;
        break;
      case CollisionAlign.BOTTOM_RIGHT:
        top = displacement.bottom - collision.height;
        left = displacement.right - collision.width;
        break;
    }
    return Rect.fromLTWH(left, top, collision.width, collision.height);
  }

  void drawCollision(Canvas canvas, Rect currentPosition, Color color) {
    if (collision == null) return;
    canvas.drawRect(
      getRectCollision(currentPosition),
      new Paint()..color = color ?? Colors.lightGreenAccent.withOpacity(0.5),
    );
  }
}
