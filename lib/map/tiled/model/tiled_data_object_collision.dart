import 'package:flame/collisions.dart';

class TiledDataObjectCollision {
  final List<ShapeHitbox>? collisions;
  final String type;
  final Map<String, dynamic>? properties;

  TiledDataObjectCollision({
    this.collisions,
    this.type = '',
    this.properties,
  });
}
