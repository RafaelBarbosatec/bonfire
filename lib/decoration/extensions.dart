import 'dart:ui';

import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/player/player.dart';

/// Functions util to use in your [GameDecoration]
extension GameDecorationExtensions on GameDecoration {
  /// This method we notify when detect the player when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  void seePlayer({
    required Function(Player) observed,
    VoidCallback? notObserved,
    int radiusVision = 3,
  }) {
    Player? player = gameRef.player;
    if (!isVisibleInCamera() || player == null) return;

    if (player.isDead) {
      notObserved?.call();
      return;
    }

    double visionWidth = position.width * radiusVision * 2;
    double visionHeight = position.height * radiusVision * 2;

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
