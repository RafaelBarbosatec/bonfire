import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/map/tile/tile_model.dart';

class TiledItemTileSet {
  final TileModelAnimation? animation;
  final TileModelSprite? sprite;
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
