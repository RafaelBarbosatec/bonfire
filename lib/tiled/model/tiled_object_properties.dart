import 'package:bonfire/bonfire.dart';

class TiledObjectProperties {
  final Vector2 position;
  final Vector2 size;
  final double? rotation;
  final String? type;
  final String? name;
  final int? id;
  final Map<String, dynamic> others;
  final ShapeHitbox area;

  TiledObjectProperties(
    this.position,
    this.size,
    this.type,
    this.rotation,
    this.others,
    this.name,
    this.id,
    this.area,
  );

  @override
  String toString() {
    return 'TiledObjectProperties{position: $position, size: $size, rotation: $rotation, type: $type, name: $name, id: $id, others: $others}';
  }
}
