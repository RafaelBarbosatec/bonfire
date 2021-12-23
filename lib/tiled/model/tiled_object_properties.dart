import 'dart:ui';

import 'package:flame/components.dart';

class TiledObjectProperties {
  final Vector2 position;
  final Size size;
  final double? rotation;
  final String? type;
  final String? name;
  final int? id;
  final Map<String, dynamic> others;

  TiledObjectProperties(
    this.position,
    this.size,
    this.type,
    this.rotation,
    this.others,
    this.name,
    this.id,
  );
}
