import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/pages/mini_games/random_map/player/pirate_sprite_sheet.dart';

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
class Pirate extends SimplePlayer with BlockMovementCollision {
  Pirate({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(DungeonMap.tileSize * 1.5),
          animation: PirateSpriteSheet.getAnimation(),
          speed: DungeonMap.tileSize * 3,
        ) {
    setupMovementByJoystick(
      diagonalEnabled: false,
    );
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(size.x / 3, size.y / 3),
        position: Vector2(size.x * 1 / 3, size.y * 2 / 3),
      ),
    );
    return super.onLoad();
  }
}
