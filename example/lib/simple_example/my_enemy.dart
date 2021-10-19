import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/enemy_sprite_sheet.dart';
import 'package:flutter/material.dart';

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
/// on 19/10/21
class MyEnemy extends SimpleEnemy with ObjectCollision {
  MyEnemy(Vector2 position)
      : super(
          animation: EnemySpriteSheet.simpleDirectionAnimation,
          position: position,
          width: 32,
          height: 32,
          life: 100,
        ) {
    /// here we configure collision of the enemy
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(size: Size(32, 32)),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    seeAndMoveToPlayer(
      closePlayer: (player) {
        /// do anything when close to player
      },
      radiusVision: 64,
    );
    super.update(dt);
  }
}
