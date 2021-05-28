import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/util/controlled_update_animation.dart';

class TileWithCollision extends Tile with ObjectCollision {
  TileWithCollision(
    String spritePath,
    Vector2 position, {
    double width = 32,
    double height = 32,
    String? type,
    Iterable<CollisionArea>? collisions,
    double offsetX = 0,
    double offsetY = 0,
    Map<String, dynamic>? properties,
  }) : super(
          spritePath,
          position,
          width: width,
          height: height,
          type: type,
          properties: properties,
        ) {
    collisions?.let((c) {
      setupCollision(CollisionConfig(collisions: c));
    });
  }

  TileWithCollision.withSprite(
    Future<Sprite> sprite,
    Vector2 position, {
    double width = 32,
    double height = 32,
    String? type,
    Iterable<CollisionArea>? collisions,
    double offsetX = 0,
    double offsetY = 0,
    Map<String, dynamic>? properties,
  }) : super.fromSprite(
          sprite,
          position,
          width: width,
          height: height,
          type: type,
          properties: properties,
        ) {
    collisions?.let((c) {
      setupCollision(CollisionConfig(collisions: c));
    });
  }

  TileWithCollision.withAnimation(
    ControlledUpdateAnimation animation,
    Vector2 position, {
    double width = 32,
    double height = 32,
    String? type,
    Iterable<CollisionArea>? collisions,
    double offsetX = 0,
    double offsetY = 0,
    Map<String, dynamic>? properties,
  }) : super.fromAnimation(
          animation,
          position,
          width: width,
          height: height,
          type: type,
          properties: properties,
        ) {
    collisions?.let((c) {
      setupCollision(CollisionConfig(collisions: c));
    });
  }
}
