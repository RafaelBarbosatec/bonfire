import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';

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

double getSizeByTileSize(double size) {
  return size * (DungeonMap.tileSize / 16);
}

class Tree extends GameDecoration {
  Tree(Vector2 position)
      : super.withSprite(
          sprite: Sprite.load('tile_random/tree.png'),
          position: position,
          size: Vector2(
            getSizeByTileSize(64),
            getSizeByTileSize(48),
          ),
        );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(getSizeByTileSize(32), getSizeByTileSize(16)),
        position: Vector2(
          getSizeByTileSize(16),
          getSizeByTileSize(32),
        ),
      ),
    );
    return super.onLoad();
  }

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    if (other is Tree) {
      return false;
    }
    return super.onComponentTypeCheck(other);
  }
}
