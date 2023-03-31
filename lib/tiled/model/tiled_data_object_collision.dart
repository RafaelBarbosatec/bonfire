import 'package:flame/geometry.dart';

class TiledDataObjectCollision {
  final List<ShapeComponent>? collisions;
  final String type;
  final Map<String, dynamic>? properties;

  TiledDataObjectCollision({
    this.collisions,
    this.type = '',
    this.properties,
  });
}
