import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

class BarrelDraggable extends GameDecoration
    with DragGesture, ObjectCollision, Movement, Pushable {
  late TextPaint _textConfig;

  BarrelDraggable(Vector2 position)
      : super.withSprite(
            sprite: CommonSpriteSheet.barrelSprite,
            position: position,
            size: Vector2.all(DungeonMap.tileSize)) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(
              DungeonMap.tileSize * 0.6,
              DungeonMap.tileSize * 0.4,
            ),
            align: Vector2(
              DungeonMap.tileSize * 0.2,
              DungeonMap.tileSize * 0.4,
            ),
          ),
        ],
      ),
    );
    _textConfig = TextPaint(
      style: TextStyle(color: Colors.white, fontSize: width / 4),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _textConfig.render(
      canvas,
      'Drag',
      Vector2(this.x + width / 5, this.y - width / 3),
    );
  }
}
