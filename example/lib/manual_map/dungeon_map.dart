import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/decoration/barrel_dragable.dart';
import 'package:example/decoration/chest.dart';
import 'package:example/decoration/spikes.dart';
import 'package:example/decoration/torch.dart';
import 'package:example/enemy/goblin.dart';
import 'package:flutter/material.dart';

class DungeonMap {
  static double tileSize = 45;
  static final Future<Sprite> wallBottom = Sprite.load('tile/wall_bottom.png');
  static final Future<Sprite> wall = Sprite.load('tile/wall.png');
  static final Future<Sprite> wallTop = Sprite.load('tile/wall_top.png');
  static final Future<Sprite> wallLeft = Sprite.load('tile/wall_left.png');
  static final Future<Sprite> wallBottomLeft =
      Sprite.load('tile/wall_bottom_left.png');
  static final Future<Sprite> wallRight = Sprite.load('tile/wall_right.png');
  static final Future<Sprite> floor_1 = Sprite.load('tile/floor_1.png');
  static final Future<Sprite> floor_2 = Sprite.load('tile/floor_2.png');
  static final Future<Sprite> floor_3 = Sprite.load('tile/floor_3.png');
  static final Future<Sprite> floor_4 = Sprite.load('tile/floor_4.png');

  static MapWorld map() {
    List<Tile> tileList = [];
    List.generate(35, (indexRow) {
      List.generate(70, (indexColumm) {
        if (indexRow == 3 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(TileWithCollision.withSprite(
            wallBottom,
            Vector2(indexColumm.toDouble(), indexRow.toDouble()),
            collisions: [
              CollisionArea.rectangle(size: Size(tileSize, tileSize))
            ],
            width: tileSize,
            height: tileSize,
          ));
          return;
        }
        if (indexRow == 4 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(TileWithCollision.withSprite(
            wall,
            Vector2(indexColumm.toDouble(), indexRow.toDouble()),
            collisions: [
              CollisionArea.rectangle(size: Size(tileSize, tileSize))
            ],
            width: tileSize,
            height: tileSize,
          ));
          return;
        }

        if (indexRow == 9 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(TileWithCollision.withSprite(
            wallTop,
            Vector2(indexColumm.toDouble(), indexRow.toDouble()),
            collisions: [
              CollisionArea.rectangle(size: Size(tileSize, tileSize))
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
            Tile.fromSprite(
              randomFloor(),
              Vector2(indexColumm.toDouble(), indexRow.toDouble()),
              width: tileSize,
              height: tileSize,
            ),
          );
          return;
        }

        if (indexRow > 3 && indexRow < 9 && indexColumm == 2) {
          tileList.add(TileWithCollision.withSprite(
            wallLeft,
            Vector2(indexColumm.toDouble(), indexRow.toDouble()),
            collisions: [
              CollisionArea.rectangle(size: Size(tileSize, tileSize))
            ],
            width: tileSize,
            height: tileSize,
          ));
        }
        if (indexRow == 9 && indexColumm == 2) {
          tileList.add(TileWithCollision.withSprite(
            wallBottomLeft,
            Vector2(indexColumm.toDouble(), indexRow.toDouble()),
            collisions: [
              CollisionArea.rectangle(size: Size(tileSize, tileSize))
            ],
            width: tileSize,
            height: tileSize,
          ));
        }

        if (indexRow > 3 && indexRow < 9 && indexColumm == 30) {
          tileList.add(TileWithCollision.withSprite(
            wallRight,
            Vector2(indexColumm.toDouble(), indexRow.toDouble()),
            collisions: [
              CollisionArea.rectangle(size: Size(tileSize, tileSize))
            ],
            width: tileSize,
            height: tileSize,
          ));
        }

        if (indexRow == 13 && indexColumm == 31) {
          tileList.add(
            Tile(
              '',
              Vector2(indexColumm.toDouble(), indexRow.toDouble()),
              width: tileSize,
              height: tileSize,
            ),
          );
          return;
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
        Sprite.load('itens/barrel.png'),
        getRelativeTilePosition(10, 6),
        width: tileSize,
        height: tileSize,
        collisions: [
          CollisionArea.rectangle(size: Size(tileSize / 1.5, tileSize / 1.5))
        ],
      ),
      Chest(getRelativeTilePosition(18, 7)),
      GameDecorationWithCollision.withSprite(
        Sprite.load('itens/table.png'),
        getRelativeTilePosition(15, 7),
        width: tileSize,
        height: tileSize,
        collisions: [
          CollisionArea.rectangle(size: Size(tileSize, tileSize * 0.8)),
        ],
      ),
      GameDecorationWithCollision.withSprite(
        Sprite.load('itens/table.png'),
        getRelativeTilePosition(27, 6),
        width: tileSize,
        height: tileSize,
        collisions: [
          CollisionArea.rectangle(size: Size(tileSize, tileSize * 0.8)),
        ],
      ),
      Torch(getRelativeTilePosition(4, 4)),
      Torch(getRelativeTilePosition(12, 4)),
      Torch(getRelativeTilePosition(20, 4)),
      Torch(getRelativeTilePosition(28, 4)),
      GameDecoration.withSprite(
        Sprite.load('itens/flag_red.png'),
        position: getRelativeTilePosition(24, 4),
        width: tileSize,
        height: tileSize,
      ),
      GameDecoration.withSprite(
        Sprite.load('itens/flag_red.png'),
        position: getRelativeTilePosition(6, 4),
        width: tileSize,
        height: tileSize,
      ),
      GameDecoration.withSprite(
        Sprite.load('itens/prisoner.png'),
        position: getRelativeTilePosition(10, 4),
        width: tileSize,
        height: tileSize,
      ),
      GameDecoration.withSprite(
        Sprite.load('itens/flag_red.png'),
        position: getRelativeTilePosition(14, 4),
        width: tileSize,
        height: tileSize,
      )
    ];
  }

  static List<Enemy> enemies() {
    return [
      Goblin(getRelativeTilePosition(14, 6)),
      Goblin(getRelativeTilePosition(25, 6)),
    ];
  }

  static Future<Sprite> randomFloor() {
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
