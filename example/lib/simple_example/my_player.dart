import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/player_sprite_sheet.dart';
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
class MyPlayer extends SimplePlayer with ObjectCollision {
  MyPlayer(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          width: 32,
          height: 32,
          position: position,
          life: 200,
        ) {
    /// here we configure collision of the player
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(size: Size(32, 32)),
        ],
      ),
    );
  }
}
