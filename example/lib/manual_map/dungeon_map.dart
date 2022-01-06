import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/shared/decoration/barrel_dragable.dart';
import 'package:example/shared/decoration/chest.dart';
import 'package:example/shared/decoration/spikes.dart';
import 'package:example/shared/decoration/torch.dart';
import 'package:example/shared/enemy/goblin.dart';

class DungeonMap {
  static double tileSize = 45;
  static final String wallBottom = 'tile/wall_bottom.png';
  static final String wall = 'tile/wall.png';
  static final String wallTop = 'tile/wall_top.png';
  static final String wallLeft = 'tile/wall_left.png';
  static final String wallBottomLeft = 'tile/wall_bottom_left.png';
  static final String wallRight = 'tile/wall_right.png';
  static final String floor_1 = 'tile/floor_1.png';
  static final String floor_2 = 'tile/floor_2.png';
  static final String floor_3 = 'tile/floor_3.png';
  static final String floor_4 = 'tile/floor_4.png';

  static MapWorld map() {
    List<TileModel> tileList = [];
    List.generate(35, (indexRow) {
      List.generate(70, (indexColumm) {
        if (indexRow == 3 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(TileModel(
            sprite: TileModelSprite(path: wallBottom),
            x: indexColumm.toDouble(),
            y: indexRow.toDouble(),
            collisions: [
              CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
            ],
            width: tileSize,
            height: tileSize,
          ));
          return;
        }
        if (indexRow == 4 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(TileModel(
            sprite: TileModelSprite(path: wall),
            x: indexColumm.toDouble(),
            y: indexRow.toDouble(),
            collisions: [
              CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
            ],
            width: tileSize,
            height: tileSize,
          ));
          return;
        }

        if (indexRow == 9 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(TileModel(
            sprite: TileModelSprite(path: wallTop),
            x: indexColumm.toDouble(),
            y: indexRow.toDouble(),
            collisions: [
              CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
            ],
            width: tileSize,
            height: tileSize,
          ));
          return;
        }

        if (indexRow > 4 &&
            indexRow < 9 &&
            indexColumm > 2 &&
            indexColumm < 30) {
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: randomFloor()),
              x: indexColumm.toDouble(),
              y: indexRow.toDouble(),
              width: tileSize,
              height: tileSize,
            ),
          );
          return;
        }

        if (indexRow > 3 && indexRow < 9 && indexColumm == 2) {
          tileList.add(TileModel(
            sprite: TileModelSprite(path: wallLeft),
            x: indexColumm.toDouble(),
            y: indexRow.toDouble(),
            collisions: [
              CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
            ],
            width: tileSize,
            height: tileSize,
          ));
        }
        if (indexRow == 9 && indexColumm == 2) {
          tileList.add(TileModel(
            sprite: TileModelSprite(path: wallBottomLeft),
            x: indexColumm.toDouble(),
            y: indexRow.toDouble(),
            collisions: [
              CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
            ],
            width: tileSize,
            height: tileSize,
          ));
        }

        if (indexRow > 3 && indexRow < 9 && indexColumm == 30) {
          tileList.add(TileModel(
            sprite: TileModelSprite(path: wallRight),
            x: indexColumm.toDouble(),
            y: indexRow.toDouble(),
            collisions: [
              CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
            ],
            width: tileSize,
            height: tileSize,
          ));
        }
      });
    });

    return MapWorld(tileList);
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
          CollisionArea.rectangle(size: Vector2(tileSize / 1.5, tileSize / 1.5))
        ],
      ),
      Chest(getRelativeTilePosition(18, 7)),
      GameDecorationWithCollision.withSprite(
        sprite: Sprite.load('itens/table.png'),
        position: getRelativeTilePosition(15, 7),
        size: Vector2(tileSize, tileSize),
        collisions: [
          CollisionArea.rectangle(size: Vector2(tileSize, tileSize * 0.8)),
        ],
      ),
      GameDecorationWithCollision.withSprite(
        sprite: Sprite.load('itens/table.png'),
        position: getRelativeTilePosition(27, 6),
        size: Vector2(tileSize, tileSize),
        collisions: [
          CollisionArea.rectangle(size: Vector2(tileSize, tileSize * 0.8)),
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
