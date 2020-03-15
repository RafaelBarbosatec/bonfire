import 'dart:ui';

import 'package:bonfire/rpg_game.dart';

class ObjectCollision {
  double heightCollision = 0;
  double widthCollision = 0;

  bool isCollision(Rect displacement, RPGGame game) {
    Rect rectCollision = Rect.fromLTWH(
        displacement.left + (displacement.width - widthCollision) / 2,
        displacement.top + (displacement.height - heightCollision),
        widthCollision,
        heightCollision);

    var collisions = game.map
        .getCollisionsRendered()
        .where((i) => i.collision && i.position.overlaps(rectCollision))
        .toList();

    if (collisions.length > 0) {
      return true;
    }

    if (game.decorations != null) {
      var collisionsDecorations = game.decorations
          .where((i) => i.collision && i.position.overlaps(rectCollision))
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
}
