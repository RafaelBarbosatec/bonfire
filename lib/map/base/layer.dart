import 'package:bonfire/bonfire.dart';

class Layer {
  final int? id;
  final String? name;
  final String? layerClass;
  final bool visible;
  final Vector2 position;
  final Vector2 offset;
  final double opacity;
  final Map<String, dynamic>? properties;
  final int priority;
  List<Tile> tiles = [];

  Layer({
    required this.id,
    required this.tiles,
    this.name,
    this.layerClass,
    this.visible = true,
    Vector2? position,
    Vector2? offset,
    this.opacity = 1,
    this.properties,
    this.priority = 0,
  })  : position = position ?? Vector2.zero(),
        offset = offset ?? Vector2.zero();
}
