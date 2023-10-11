import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';

class ColumnDecoration extends GameDecoration {
  ColumnDecoration(Vector2 position)
      : super.withSprite(
          sprite: CommonSpriteSheet.columnSprite,
          position: position,
          size: Vector2(DungeonMap.tileSize, DungeonMap.tileSize * 3),
        );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          DungeonMap.tileSize * 0.8,
          DungeonMap.tileSize / 2,
        ),
        position: Vector2(
          DungeonMap.tileSize * 0.1,
          DungeonMap.tileSize * 1.8,
        ),
      ),
    );
    return super.onLoad();
  }
}
