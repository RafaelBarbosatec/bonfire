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
  static final Sprite wall_bottom = Sprite('tile/wall_bottom.png');
  static final Sprite wall = Sprite('tile/wall.png');
  static final Sprite wall_top = Sprite('tile/wall_top.png');
  static final Sprite wall_left = Sprite('tile/wall_left.png');
  static final Sprite wall_bottom_left = Sprite('tile/wall_bottom_left.png');
  static final Sprite wall_right = Sprite('tile/wall_right.png');
  static final Sprite floor_1 = Sprite('tile/floor_1.png');
  static final Sprite floor_2 = Sprite('tile/floor_2.png');
  static final Sprite floor_3 = Sprite('tile/floor_3.png');
  static final Sprite floor_4 = Sprite('tile/floor_4.png');

  static MapWorld map() {
    List<Tile> tileList = List();
    List.generate(35, (indexRow) {
      List.generate(70, (indexColumm) {
        if (indexRow == 3 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(Tile.fromSprite(wall_bottom,
              Position(indexColumm.toDouble(), indexRow.toDouble()),
              collision: Collision.fromSize(tileSize),
              width: tileSize,
              height: tileSize));
          return;
        }
        if (indexRow == 4 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(Tile.fromSprite(
              wall, Position(indexColumm.toDouble(), indexRow.toDouble()),
              collision: Collision.fromSize(tileSize),
              width: tileSize,
              height: tileSize));
          return;
        }

        if (indexRow == 9 && indexColumm > 2 && indexColumm < 30) {
          tileList.add(Tile.fromSprite(
              wall_top, Position(indexColumm.toDouble(), indexRow.toDouble()),
              collision: Collision.fromSize(tileSize),
              width: tileSize,
              height: tileSize));
          return;
        }

        if (indexRow > 4 &&
            indexRow < 9 &&
            indexColumm > 2 &&
            indexColumm < 30) {
          tileList.add(Tile.fromSprite(randomFloor(),
              Position(indexColumm.toDouble(), indexRow.toDouble()),
              width: tileSize, height: tileSize));
          return;
        }

        if (indexRow > 3 && indexRow < 9 && indexColumm == 2) {
          tileList.add(Tile.fromSprite(
              wall_left, Position(indexColumm.toDouble(), indexRow.toDouble()),
              collision: Collision.fromSize(tileSize),
              width: tileSize,
              height: tileSize));
        }
        if (indexRow == 9 && indexColumm == 2) {
          tileList.add(Tile.fromSprite(wall_bottom_left,
              Position(indexColumm.toDouble(), indexRow.toDouble()),
              collision: Collision.fromSize(tileSize),
              width: tileSize,
              height: tileSize));
        }

        if (indexRow > 3 && indexRow < 9 && indexColumm == 30) {
          tileList.add(Tile.fromSprite(
              wall_right, Position(indexColumm.toDouble(), indexRow.toDouble()),
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

  static Sprite randomFloor() {
    int p = Random().nextInt(6);
    switch (p) {
      case 0:
        return floor_1;
        break;
      case 1:
        return floor_2;
        break;
      case 2:
        return floor_3;
        break;
      case 3:
        return floor_4;
        break;
      case 4:
        return floor_3;
        break;
      case 5:
        return floor_4;
        break;
      default:
        return floor_1;
    }
  }

  static Position getRelativeTilePosition(int x, int y) {
    return Position(
      (x * tileSize).toDouble(),
      (y * tileSize).toDouble(),
    );
  }
}
