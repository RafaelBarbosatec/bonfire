import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/controlled_update_animation.dart';

class TileWithCollision extends Tile with ObjectCollision {
  TileWithCollision({
    required String spritePath,
    required Vector2 position,
    required Vector2 size,
    String? type,
    Iterable<CollisionArea>? collisions,
    double offsetX = 0,
    double offsetY = 0,
    Map<String, dynamic>? properties,
  }) : super(
          spritePath: spritePath,
          position: position,
          size: size,
          type: type,
          offsetX: offsetX,
          offsetY: offsetY,
          properties: properties,
        ) {
    if (collisions != null) {
      setupCollision(CollisionConfig(collisions: collisions));
    }
  }

  TileWithCollision.fromSprite({
    required Sprite? sprite,
    required Vector2 position,
    required Vector2 size,
    String? type,
    Iterable<CollisionArea>? collisions,
    double offsetX = 0,
    double offsetY = 0,
    Color? color,
    Map<String, dynamic>? properties,
  }) : super.fromSprite(
          sprite: sprite,
          position: position,
          size: size,
          type: type,
          offsetX: offsetX,
          offsetY: offsetY,
          properties: properties,
          color: color,
        ) {
    if (collisions != null) {
      setupCollision(CollisionConfig(collisions: collisions));
    }
  }

  TileWithCollision.withAnimation({
    required ControlledUpdateAnimation animation,
    required Vector2 position,
    required Vector2 size,
    String? type,
    Iterable<CollisionArea>? collisions,
    double offsetX = 0,
    double offsetY = 0,
    Map<String, dynamic>? properties,
  }) : super.fromAnimation(
          animation: animation,
          position: position,
          size: size,
          offsetX: offsetX,
          offsetY: offsetY,
          type: type,
          properties: properties,
        ) {
    if (collisions != null) {
      setupCollision(CollisionConfig(collisions: collisions));
    }
  }
}
