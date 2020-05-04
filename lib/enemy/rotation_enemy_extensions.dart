import 'dart:math';

import 'package:bonfire/enemy/extensions.dart';
import 'package:bonfire/enemy/rotation_enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:flutter/rendering.dart';

extension RotationEnemyExtensions on RotationEnemy {
  void seeAndMoveToPlayer({
    Function(Player) closePlayer,
    int visionCells = 3,
    double margin = 10,
  }) {
    if (!isVisibleInMap() || isDead || this.position == null) return;
    seePlayer(
      visionCells: visionCells,
      observed: (player) {
        double _radAngle = atan2(
            player.positionInWorld.center.dy - this.positionInWorld.center.dy,
            player.positionInWorld.center.dx - this.positionInWorld.center.dx);

        Rect rectPlayerCollision = Rect.fromLTWH(
          player.rectCollision.left - margin,
          player.rectCollision.top - margin,
          player.rectCollision.width + (margin * 2),
          player.rectCollision.height + (margin * 2),
        );

        if (this.rectCollision.overlaps(rectPlayerCollision)) {
          if (closePlayer != null) closePlayer(player);
          this.idle();
          return;
        }

        this.moveFromAngleDodgeObstacles(speed, _radAngle, notMove: () {
          this.idle();
        });
      },
      notObserved: () {
        this.idle();
      },
    );
  }
}
