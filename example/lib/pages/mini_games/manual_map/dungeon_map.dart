import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/base/layer.dart';
import 'package:example/shared/decoration/barrel_dragable.dart';
import 'package:example/shared/decoration/chest.dart';
import 'package:example/shared/decoration/spikes.dart';
import 'package:example/shared/decoration/torch.dart';
import 'package:example/shared/enemy/goblin.dart';

class DungeonMap {
  static double tileSize = 45;
  static const String wallBottom = 'tile/wall_bottom.png';
  static const String wall = 'tile/wall.png';
  static const String wallTop = 'tile/wall_top.png';
  static const String wallLeft = 'tile/wall_left.png';
  static const String wallBottomLeft = 'tile/wall_bottom_left.png';
  static const String wallRight = 'tile/wall_right.png';
  static const String floor_1 = 'tile/floor_1.png';
  static const String floor_2 = 'tile/floor_2.png';
  static const String floor_3 = 'tile/floor_3.png';
  static const String floor_4 = 'tile/floor_4.png';

  static void generateMap(
    List<Tile> tileList,
    int indexRow,
    int indexColumn,
    String pngImage,
  ) {
    tileList.add(
      Tile(
        sprite: TileSprite(path: pngImage),
        x: indexColumn.toDouble(),
        y: indexRow.toDouble(),
        collisions: [RectangleHitbox(size: Vector2(tileSize, tileSize))],
        width: tileSize,
        height: tileSize,
      ),
    );
  }

  static WorldMap map() {
    List<Tile> tileList = [];
    List.generate(35, (indexRow) {
      List.generate(70, (indexColumn) {
        if (indexRow == 3 && indexColumn > 2 && indexColumn < 30) {
          generateMap(
            tileList,
            indexRow,
            indexColumn,
            wallBottom,
          );
          return;
        }
        if (indexRow == 4 && indexColumn > 2 && indexColumn < 30) {
          generateMap(
            tileList,
            indexRow,
            indexColumn,
            wall,
          );
          return;
        }

        if (indexRow == 9 && indexColumn > 2 && indexColumn < 30) {
          generateMap(
            tileList,
            indexRow,
            indexColumn,
            wallTop,
          );
          return;
        }

        if (indexRow > 4 &&
            indexRow < 9 &&
            indexColumn > 2 &&
            indexColumn < 30) {
          tileList.add(
            Tile(
              sprite: TileSprite(path: randomFloor()),
              x: indexColumn.toDouble(),
              y: indexRow.toDouble(),
              width: tileSize,
              height: tileSize,
            ),
          );
          return;
        }

        if (indexRow > 3 && indexRow < 9 && indexColumn == 2) {
          generateMap(
            tileList,
            indexRow,
            indexColumn,
            wallLeft,
          );
        }
        if (indexRow == 9 && indexColumn == 2) {
          generateMap(
            tileList,
            indexRow,
            indexColumn,
            wallBottomLeft,
          );
        }

        if (indexRow > 3 && indexRow < 9 && indexColumn == 30) {
          generateMap(
            tileList,
            indexRow,
            indexColumn,
            wallRight,
          );
        }
      });
    });

    return WorldMap([Layer(id: 0, tiles: tileList)]);
  }

  static List<GameDecoration> decorations() {
    return [
      Spikes(
        getRelativeTilePosition(7, 7),
      ),
      BarrelDraggable(getRelativeTilePosition(8, 6)),
      GameDecorationWithCollision.withSprite(
        sprite: Sprite.load('itens/barrel.png'),
        position: getRelativeTilePosition(10, 6),
        size: Vector2(tileSize, tileSize),
        collisions: [
          RectangleHitbox(size: Vector2(tileSize / 1.5, tileSize / 1.5))
        ],
      ),
      Chest(getRelativeTilePosition(18, 7)),
      GameDecorationWithCollision.withSprite(
        sprite: Sprite.load('itens/table.png'),
        position: getRelativeTilePosition(15, 7),
        size: Vector2(tileSize, tileSize),
        collisions: [
          RectangleHitbox(size: Vector2(tileSize, tileSize * 0.8)),
        ],
      ),
      GameDecorationWithCollision.withSprite(
        sprite: Sprite.load('itens/table.png'),
        position: getRelativeTilePosition(27, 6),
        size: Vector2(tileSize, tileSize),
        collisions: [
          RectangleHitbox(size: Vector2(tileSize, tileSize * 0.8)),
        ],
      ),
      Torch(getRelativeTilePosition(4, 4)),
      Torch(getRelativeTilePosition(12, 4)),
      Torch(getRelativeTilePosition(20, 4)),
      Torch(getRelativeTilePosition(28, 4)),
      GameDecoration.withSprite(
        sprite: Sprite.load('itens/flag_red.png'),
        position: getRelativeTilePosition(24, 4),
        size: Vector2(tileSize, tileSize),
      ),
      GameDecoration.withSprite(
        sprite: Sprite.load('itens/flag_red.png'),
        position: getRelativeTilePosition(6, 4),
        size: Vector2(tileSize, tileSize),
      ),
      GameDecoration.withSprite(
        sprite: Sprite.load('itens/prisoner.png'),
        position: getRelativeTilePosition(10, 4),
        size: Vector2(tileSize, tileSize),
      ),
      GameDecoration.withSprite(
        sprite: Sprite.load('itens/flag_red.png'),
        position: getRelativeTilePosition(14, 4),
        size: Vector2(tileSize, tileSize),
      )
    ];
  }

  static List<Enemy> enemies() {
    return [
      Goblin(getRelativeTilePosition(14, 6)),
      Goblin(getRelativeTilePosition(25, 6)),
    ];
  }

  static String randomFloor() {
    int p = Random().nextInt(6);
    switch (p) {
      case 0:
        return floor_1;
      case 1:
        return floor_2;
      case 2:
        return floor_3;
      case 3:
        return floor_4;
      case 4:
        return floor_3;
      case 5:
        return floor_4;
      default:
        return floor_1;
    }
  }

  static Vector2 getRelativeTilePosition(int x, int y) {
    return Vector2(
      (x * tileSize).toDouble(),
      (y * tileSize).toDouble(),
    );
  }
}
