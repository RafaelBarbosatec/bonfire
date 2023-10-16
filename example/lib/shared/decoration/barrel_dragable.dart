import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

class BarrelDraggable extends GameDecoration
    with Movement, BlockMovementCollision {
  bool enableBlock = true;
  BarrelDraggable(Vector2 position)
      : super.withSprite(
          sprite: CommonSpriteSheet.barrelSprite,
          position: position,
          size: Vector2.all(DungeonMap.tileSize),
        );

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    if (enableBlock) {
      return super.onBlockMovement(intersectionPoints, other);
    }
    return false;
  }

  @override
  void onBlockedMovement(
      PositionComponent other, Direction? direction, Vector2 lastDisplacement) {
    switch (direction) {
      case Direction.left:
        translate(Vector2(DungeonMap.tileSize, 0));
        break;
      case Direction.right:
        translate(Vector2(-DungeonMap.tileSize, 0));
        break;
      case Direction.up:
        translate(Vector2(0, DungeonMap.tileSize));
        break;
      case Direction.down:
        translate(Vector2(0, -DungeonMap.tileSize));
        break;
      default:
    }
    _correctPosition();
    super.onBlockedMovement(other, direction, lastDisplacement);
  }

  void _correctPosition() {
    double restX = x % DungeonMap.tileSize;
    double restY = y % DungeonMap.tileSize;
    if (restX < DungeonMap.tileSize / 2) {
      restX = -restX;
    } else {
      restX = DungeonMap.tileSize - restX;
    }

    if (restY < DungeonMap.tileSize / 2) {
      restY = -restY;
    } else {
      restY = DungeonMap.tileSize - restY;
    }

    enableBlock = false;
    add(MoveToEffect(
      position.translated(restX, restY),
      EffectController(duration: 0.5, curve: Curves.decelerate),
      onComplete: () {
        enableBlock = true;
      },
    ));

    // position += Vector2(
    //   restX,
    //   restY,
    // );
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
