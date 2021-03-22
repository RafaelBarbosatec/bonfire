import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:flame/components.dart';

class GameDecorationWithCollision extends GameDecoration with ObjectCollision {
  GameDecorationWithCollision(
    Vector2 position, {
    Sprite sprite,
    SpriteAnimation animation,
    double width = 32,
    double height = 32,
    String type,
    Iterable<CollisionArea> collisions,
    double offsetX = 0,
    double offsetY = 0,
    bool frontFromPlayer = false,
  }) : super(
          position: position,
          height: height,
          width: width,
          frontFromPlayer: frontFromPlayer,
          animation: animation,
          sprite: sprite,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: collisions,
      ),
    );
  }

  GameDecorationWithCollision.withSprite(
    Sprite sprite,
    Vector2 position, {
    double width = 32,
    double height = 32,
    String type,
    Iterable<CollisionArea> collisions,
    double offsetX = 0,
    double offsetY = 0,
    bool frontFromPlayer = false,
  }) : super.sprite(
          sprite,
          position: position,
          height: height,
          width: width,
          frontFromPlayer: frontFromPlayer,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: collisions,
      ),
    );
  }

  GameDecorationWithCollision.withAnimation(
    SpriteAnimation animation,
    Vector2 position, {
    double width = 32,
    double height = 32,
    String type,
    Iterable<CollisionArea> collisions,
    double offsetX = 0,
    double offsetY = 0,
    bool frontFromPlayer = false,
  }) : super.animation(
          animation,
          position: position,
          height: height,
          width: width,
          frontFromPlayer: frontFromPlayer,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: collisions,
      ),
    );
  }
}
