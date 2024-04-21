import 'package:bonfire/bonfire.dart';

class TiledItemTileSet {
  final TilelAnimation? animation;
  final TileSprite? sprite;
  final List<ShapeHitbox>? collisions;
  final String? type;
  final String? tileClass;
  final Map<String, dynamic>? properties;
  final double angle;
  final bool isFlipVertical;
  final bool isFlipHorizontal;

  TiledItemTileSet({
    this.sprite,
    this.collisions,
    this.animation,
    this.type,
    this.tileClass,
    this.properties,
    this.angle = 0,
    this.isFlipVertical = false,
    this.isFlipHorizontal = false,
  });
}
