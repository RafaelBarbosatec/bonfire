import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/random_map/player/pirate_sprite_sheet.dart';

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
/// on 03/06/22
class Pirate extends SimplePlayer with ObjectCollision {
  Pirate({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(DungeonMap.tileSize * 1.5),
          animation: PirateSpriteSheet.getAnimation(),
        ) {
    enabledDiagonalMovements = false;
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(size.x / 3, size.y / 3),
            align: Vector2(size.x * 1 / 3, size.y * 2 / 3),
          ),
        ],
      ),
    );
  }
}
