import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

class BarrelDraggable extends GameDecoration
    with Movement, BlockMovementCollision {
  BarrelDraggable(Vector2 position)
      : super.withSprite(
          sprite: CommonSpriteSheet.barrelSprite,
          position: position,
          size: Vector2.all(DungeonMap.tileSize),
        );

  @override
  void onBlockedMovement(
      PositionComponent other, Direction? direction, Vector2 lastDisplacement) {
    Vector2? positionToMove;
    switch (direction) {
      case Direction.left:
        positionToMove = position.translated(DungeonMap.tileSize, 0);
        break;
      case Direction.right:
        positionToMove = position.translated(-DungeonMap.tileSize, 0);
        break;
      case Direction.up:
        positionToMove = position.translated(0, DungeonMap.tileSize);
        break;
      case Direction.down:
        positionToMove = position.translated(0, -DungeonMap.tileSize);
        break;
      default:
    }
    if (positionToMove != null) {
      add(
        MoveToEffect(
          positionToMove,
          EffectController(duration: 0.5, curve: Curves.decelerate),
        ),
      );
    }
    super.onBlockedMovement(other, direction, lastDisplacement);
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: size / 1.5,
        position: size / 8.5,
        isSolid: true,
      ),
    );
    return super.onLoad();
  }
}
