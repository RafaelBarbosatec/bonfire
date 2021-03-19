import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';

class DecorationWithCollision extends GameDecoration with ObjectCollision {
  DecorationWithCollision(
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
}
