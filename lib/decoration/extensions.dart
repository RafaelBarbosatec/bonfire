import 'dart:ui';

import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/player/player.dart';

extension GameDecorationExtensions on GameDecoration {
  void seePlayer({
    required Function(Player) observed,
    VoidCallback? notObserved,
    int visionCells = 3,
  }) {
    Player? player = gameRef?.player;
    if (!isVisibleInCamera() || player == null) return;

    if (player.isDead) {
      notObserved?.call();
      return;
    }

    double visionWidth = position.width * visionCells * 2;
    double visionHeight = position.height * visionCells * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      position.left - (visionWidth / 2),
      position.top - (visionHeight / 2),
      visionWidth,
      visionHeight,
    );

    if (fieldOfVision.overlaps(player.position.rect)) {
      observed(player);
    } else {
      notObserved?.call();
    }
  }
}
