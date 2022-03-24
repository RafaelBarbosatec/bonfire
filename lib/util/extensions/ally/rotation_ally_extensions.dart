import 'dart:ui';

import 'package:bonfire/collision/object_collision.dart';
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
    double radiusVision = 32,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;
    if (runOnlyVisibleInScreen && !this.isVisible) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        double _radAngle = getAngleFomPlayer();

        Rect playerRect = player is ObjectCollision
            ? (player as ObjectCollision).rectCollision
            : player.toRect();
        Rect rectPlayerCollision = Rect.fromLTWH(
          playerRect.left - margin,
          playerRect.top - margin,
          playerRect.width + (margin * 2),
          playerRect.height + (margin * 2),
        );

        if (rectConsideringCollision.overlaps(rectPlayerCollision)) {
          closePlayer(player);
          this.idle();
          this.moveFromAngleDodgeObstacles(0, _radAngle);
          return;
        }

        bool onMove = this.moveFromAngleDodgeObstacles(speed, _radAngle);
        if (!onMove) {
          this.idle();
        }
      },
      notObserved: () {
        this.idle();
      },
    );
  }
}
