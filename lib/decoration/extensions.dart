import 'dart:ui';

import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/direction.dart';

extension GameDecorationExtensions on GameDecoration {
  void seePlayer({
    Function(Player) observed,
    Function() notObserved,
    int visionCells = 3,
  }) {
    Player player = gameRef.player;
    if (!isVisibleInCamera() || player == null) return;

    if (player.isDead) {
      if (notObserved != null) notObserved();
      return;
    }

    double visionWidth = position.rect.width * visionCells * 2;
    double visionHeight = position.rect.height * visionCells * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      position.rect.left - (visionWidth / 2),
      position.rect.top - (visionHeight / 2),
      visionWidth,
      visionHeight,
    );

    if (fieldOfVision.overlaps(player.position.rect)) {
      if (observed != null) observed(player);
    } else {
      if (notObserved != null) notObserved();
    }
  }

  Direction directionThatPlayerIs() {
    Player player = this.gameRef.player;
    var diffX = position.rect.center.dx - player.position.rect.center.dx;
    var diffPositiveX = diffX < 0 ? diffX *= -1 : diffX;
    var diffY = position.rect.center.dy - player.position.rect.center.dy;
    var diffPositiveY = diffY < 0 ? diffY *= -1 : diffY;

    if (diffPositiveX > diffPositiveY) {
      if (player.position.rect.center.dx > position.rect.center.dx) {
        return Direction.right;
      } else if (player.position.rect.center.dx < position.rect.center.dx) {
        return Direction.left;
      }
    } else {
      if (player.position.rect.center.dy > position.rect.center.dy) {
        return Direction.bottom;
      } else if (player.position.rect.center.dy < position.rect.center.dy) {
        return Direction.top;
      }
    }

    return Direction.left;
  }
}
