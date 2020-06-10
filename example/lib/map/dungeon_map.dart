import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/decoration/barrel_dragable.dart';
import 'package:example/decoration/chest.dart';
import 'package:example/decoration/spikes.dart';
import 'package:example/decoration/torch.dart';
import 'package:example/enemy/goblin.dart';
import 'package:flame/position.dart';

class DungeonMap {
  static const double tileSize = 45;

  static MapWorld map() {
    List<Tile> tileList = List();
    List.generate(35, (indexRow) {
      List.generate(70, (indexColumm) {
        if (indexRow == 3 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(Tile('tile/wall_bottom.png',
              Position(indexColumm.toDouble(), indexRow.toDouble()),
              collision: Collision.fromSize(tileSize),
              width: tileSize,
              height: tileSize));
          return;
        }
        if (indexRow == 4 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(Tile('tile/wall.png',
              Position(indexColumm.toDouble(), indexRow.toDouble()),
              collision: Collision.fromSize(tileSize),
              width: tileSize,
              height: tileSize));
          return;
        }

        if (indexRow == 9 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(Tile('tile/wall_top.png',
              Position(indexColumm.toDouble(), indexRow.toDouble()),
              collision: Collision.fromSize(tileSize),
              width: tileSize,
              height: tileSize));
          return;
        }

        if (indexRow > 4 &&
            indexRow < 9 &&
            indexColumm > 2 &&
            indexColumm < 30) {
          tileList.add(Tile(randomFloor(),
              Position(indexColumm.toDouble(), indexRow.toDouble()),
              width: tileSize, height: tileSize));
          return;
        }

        if (indexRow > 3 && indexRow < 9 && indexColumm == 2) {
          tileList.add(Tile('tile/wall_left.png',
              Position(indexColumm.toDouble(), indexRow.toDouble()),
              collision: Collision.fromSize(tileSize),
              width: tileSize,
              height: tileSize));
        }
        if (indexRow == 9 && indexColumm == 2) {
          tileList.add(Tile('tile/wall_bottom_left.png',
              Position(indexColumm.toDouble(), indexRow.toDouble()),
              collision: Collision.fromSize(tileSize),
              width: tileSize,
              height: tileSize));
        }

        if (indexRow > 3 && indexRow < 9 && indexColumm == 30) {
          tileList.add(Tile('tile/wall_right.png',
              Position(indexColumm.toDouble(), indexRow.toDouble()),
              collision: Collision.fromSize(tileSize),
              width: tileSize,
              height: tileSize));
        }

        if (indexRow == 13 && indexColumm == 31) {
          tileList.add(Tile(
              '', Position(indexColumm.toDouble(), indexRow.toDouble()),
              width: tileSize, height: tileSize));
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
      GameDecoration.sprite(
        Sprite('itens/barrel.png'),
        initPosition: getRelativeTilePosition(10, 6),
        width: tileSize,
        height: tileSize,
        collision: Collision(
          width: tileSize / 1.5,
          height: tileSize / 1.5,
        ),
      ),
      Chest(getRelativeTilePosition(18, 7)),
      GameDecoration.sprite(
        Sprite('itens/table.png'),
        initPosition: getRelativeTilePosition(15, 7),
        width: tileSize,
        height: tileSize,
        collision: Collision(
          height: tileSize * 0.8,
          width: tileSize,
        ),
      ),
      GameDecoration.sprite(
        Sprite('itens/table.png'),
        initPosition: getRelativeTilePosition(27, 6),
        width: tileSize,
        height: tileSize,
        collision: Collision(
          height: tileSize * 0.8,
          width: tileSize,
        ),
      ),
      Torch(getRelativeTilePosition(4, 4)),
      Torch(getRelativeTilePosition(12, 4)),
      Torch(getRelativeTilePosition(20, 4)),
      Torch(getRelativeTilePosition(28, 4)),
      GameDecoration.sprite(
        Sprite('itens/flag_red.png'),
        initPosition: getRelativeTilePosition(24, 4),
        width: tileSize,
        height: tileSize,
      ),
      GameDecoration.sprite(
        Sprite('itens/flag_red.png'),
        initPosition: getRelativeTilePosition(6, 4),
        width: tileSize,
        height: tileSize,
      ),
      GameDecoration.sprite(
        Sprite('itens/prisoner.png'),
        initPosition: getRelativeTilePosition(10, 4),
        width: tileSize,
        height: tileSize,
      ),
      GameDecoration.sprite(
        Sprite('itens/flag_red.png'),
        initPosition: getRelativeTilePosition(14, 4),
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

  static String randomFloor() {
    int p = Random().nextInt(6);
    String sprite = "";
    switch (p) {
      case 0:
        sprite = 'tile/floor_1.png';
        break;
      case 1:
        sprite = 'tile/floor_1.png';
        break;
      case 2:
        sprite = 'tile/floor_2.png';
        break;
      case 3:
        sprite = 'tile/floor_2.png';
        break;
      case 4:
        sprite = 'tile/floor_3.png';
        break;
      case 5:
        sprite = 'tile/floor_4.png';
        break;
    }
    return sprite;
  }

  static Position getRelativeTilePosition(int x, int y) {
    return Position(
      (x * tileSize).toDouble(),
      (y * tileSize).toDouble(),
    );
  }
}
