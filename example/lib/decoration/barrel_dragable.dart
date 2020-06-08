import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flutter/material.dart';

class BarrelDraggable extends GameDecoration with DragGesture {
  final TextConfig _textConfig = TextConfig(color: Colors.white, fontSize: 12);
  BarrelDraggable(Position initPosition)
      : super.sprite(
          Sprite('itens/barrel.png'),
          initPosition: initPosition,
          width: DungeonMap.tileSize,
          height: DungeonMap.tileSize,
          collision: Collision(
            width: DungeonMap.tileSize / 1.5,
            height: DungeonMap.tileSize / 1.5,
            align: CollisionAlign.CENTER,
          ),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _textConfig.render(canvas, 'Drag',
        Position(this.position.left + 10, this.position.top - 15));
  }
}
