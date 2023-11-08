import 'dart:ui';

import 'package:bonfire/npc/ally/ally.dart';

import '../../../player/player.dart';
import '../extensions.dart';

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
    if (isDead) return;
    if (runOnlyVisibleInScreen && !isVisible) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        double radAngle = getAngleFromPlayer();

        Rect playerRect = player.rectCollision;
        Rect rectPlayerCollision = Rect.fromLTWH(
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
        bool stop = notObserved?.call() ?? true;
        if (stop) {
          stopMove();
        }
      },
    );
  }
}
