import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

class BarrelDraggable extends GameDecoration with DragGesture, ObjectCollision {
  late TextPaint _textConfig;

  BarrelDraggable(Vector2 position)
      : super.withSprite(
          CommonSpriteSheet.barrelSprite,
          position: position,
          width: DungeonMap.tileSize,
          height: DungeonMap.tileSize,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Size(
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
      config: TextPaintConfig(color: Colors.white, fontSize: width / 4),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _textConfig.render(
      canvas,
      'Drag',
      Vector2(this.position.left + width / 5, this.position.top - width / 3),
    );
  }
}
