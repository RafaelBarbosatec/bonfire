import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class GameDecorationAnimatedWithCollision extends GameDecoration
    with ObjectCollision {
  GameDecorationAnimatedWithCollision(
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
