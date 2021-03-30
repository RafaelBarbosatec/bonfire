import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flutter/cupertino.dart';

class ColumnDecoration extends GameDecoration with ObjectCollision {
  ColumnDecoration(Vector2 position)
      : super.sprite(
          Sprite.load('itens/column.png'),
          position: position,
          width: DungeonMap.tileSize,
          height: DungeonMap.tileSize * 3,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea(
            width: DungeonMap.tileSize,
            height: DungeonMap.tileSize / 2,
            align: Offset(0, DungeonMap.tileSize * 1.8),
          ),
        ],
      ),
    );
  }
}
