import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:flame/components.dart';

/// GameDecoration with collision used in construct of the map with Tiled
class GameDecorationWithCollision extends GameDecoration with ObjectCollision {
  bool aboveComponents = false;

  GameDecorationWithCollision(
    Vector2 position, {
    Sprite? sprite,
    SpriteAnimation? animation,
    double width = 32,
    double height = 32,
    Iterable<CollisionArea>? collisions,
    double offsetX = 0,
    double offsetY = 0,
    this.aboveComponents = false,
  }) : super(
          position: position,
          height: height,
          width: width,
          animation: animation,
          sprite: sprite,
        ) {
    if (collisions != null) {
      setupCollision(
        CollisionConfig(collisions: collisions),
      );
    }
  }

  GameDecorationWithCollision.withSprite(
    Future<Sprite> sprite,
    Vector2 position, {
    double width = 32,
    double height = 32,
    Iterable<CollisionArea>? collisions,
    double offsetX = 0,
    double offsetY = 0,
    this.aboveComponents = false,
  }) : super.withSprite(
          sprite,
          position: position,
          height: height,
          width: width,
        ) {
    if (collisions != null) {
      setupCollision(
        CollisionConfig(collisions: collisions),
      );
    }
  }

  GameDecorationWithCollision.withAnimation(
    Future<SpriteAnimation> animation,
    Vector2 position, {
    double width = 32,
    double height = 32,
    Iterable<CollisionArea>? collisions,
    double offsetX = 0,
    double offsetY = 0,
    this.aboveComponents = false,
  }) : super.withAnimation(
          animation,
          position: position,
          height: height,
          width: width,
        ) {
    if (collisions != null) {
      setupCollision(
        CollisionConfig(collisions: collisions),
      );
    }
  }
}
