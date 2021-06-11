import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/util/controlled_update_animation.dart';
import 'package:flame/components.dart';

class TiledItemTileSet {
  final ControlledUpdateAnimation? animation;
  final Sprite? sprite;
  final List<CollisionArea>? collisions;
  final String? type;
  final Map<String, dynamic>? properties;

  TiledItemTileSet({
    this.sprite,
    this.collisions,
    this.animation,
    this.type,
    this.properties,
  });
}
