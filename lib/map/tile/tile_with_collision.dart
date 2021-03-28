import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:flame/position.dart';

class TileWithCollision extends Tile with ObjectCollision {
  TileWithCollision(
    Sprite sprite,
    Position position, {
    double width = 32,
    double height = 32,
    String type,
    Iterable<CollisionArea> collisions,
    double offsetX = 0,
    double offsetY = 0,
  }) : super.fromSprite(
          sprite,
          position,
          width: width,
          height: height,
          type: type,
        ) {
    setupCollision(CollisionConfig(collisions: collisions));
  }
}
