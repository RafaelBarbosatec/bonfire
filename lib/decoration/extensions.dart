import 'dart:ui';

import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/vector2rect.dart';

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
    if (player == null) return;

    if (player.isDead) {
      if (notObserved != null) notObserved();
      return;
    }

    double vision = radiusVision * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      this.position.center.dx - radiusVision,
      this.position.center.dy - radiusVision,
      vision,
      vision,
    );

    if (fieldOfVision.overlaps(playerRect.rect)) {
      observed(player);
    } else {
      notObserved?.call();
    }
  }

  /// Gets player position used how base in calculations
  Vector2Rect get playerRect {
    return (gameRef.player is ObjectCollision
            ? (gameRef.player as ObjectCollision).rectCollision
            : gameRef.player?.position) ??
        Vector2Rect.zero();
  }
}
