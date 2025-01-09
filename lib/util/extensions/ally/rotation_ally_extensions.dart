import 'dart:ui';

import 'package:bonfire/npc/ally/ally.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/extensions/extensions.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 24/03/22
extension RotationEnemyExtensions on RotationAlly {
  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToPlayer({
    required Function(Player) closePlayer,
    // return true to stop move.
    BoolCallback? notObserved,
    double radiusVision = 32,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if ((runOnlyVisibleInScreen && !isVisible) || isDead) {
      return;
    }

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        final radAngle = getAngleToPlayer();

        final playerRect = player.rectCollision;
        final rectPlayerCollision = Rect.fromLTWH(
          playerRect.left - margin,
          playerRect.top - margin,
          playerRect.width + (margin * 2),
          playerRect.height + (margin * 2),
        );

        if (rectCollision.overlaps(rectPlayerCollision)) {
          closePlayer(player);
          stopMove();
          return;
        }

        moveFromAngle(radAngle);
      },
      notObserved: () {
        final stop = notObserved?.call() ?? true;
        if (stop) {
          stopMove();
        }
      },
    );
  }
}
