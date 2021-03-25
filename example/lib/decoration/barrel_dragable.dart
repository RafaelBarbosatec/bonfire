import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flutter/material.dart';

class BarrelDraggable extends GameDecoration with DragGesture, ObjectCollision {
  TextConfig _textConfig;
  BarrelDraggable(Vector2 position)
      : super.sprite(
          Sprite.load('itens/barrel.png'),
          position: position,
          width: DungeonMap.tileSize,
          height: DungeonMap.tileSize,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea(
            width: DungeonMap.tileSize * 0.6,
            height: DungeonMap.tileSize * 0.8,
            align: Offset(
              DungeonMap.tileSize * 0.2,
              0,
            ),
          )
        ],
      ),
    );
    _textConfig = TextConfig(color: Colors.white, fontSize: width / 4);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _textConfig.render(
      canvas,
      'Drag',
      Vector2(this.position.rect.left + width / 5,
          this.position.rect.top - width / 3),
    );
  }
}
