import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class GameDecorationWithCollision extends GameDecoration with ObjectCollision {
  GameDecorationWithCollision(
    Position position, {
    Sprite sprite,
    double width = 32,
    double height = 32,
    String type,
    Iterable<CollisionArea> collisions,
    double offsetX = 0,
    double offsetY = 0,
    bool frontFromPlayer = false,
    FlameAnimation.Animation animation,
  }) : super(
          animation: animation,
          sprite: sprite,
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

  GameDecorationWithCollision.sprite(
    Sprite sprite,
    Position position, {
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

  GameDecorationWithCollision.animation(
    FlameAnimation.Animation animation,
    Position position, {
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
