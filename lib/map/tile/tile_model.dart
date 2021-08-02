import 'package:bonfire/collision/collision_area.dart';
import 'package:flutter/widgets.dart';

class TileModelSprite {
  final String id;
  final String path;
  final int row;
  final int column;
  final double width;
  final double height;

  TileModelSprite({
    required this.id,
    required this.path,
    required this.row,
    required this.column,
    required this.width,
    required this.height,
  });
}

class TileModelAnimation {
  final String id;
  final double stepTime;
  final List<TileModelSprite> frames;

  TileModelAnimation({
    required this.id,
    required this.stepTime,
    required this.frames,
  });
}

class TileModel {
  final double x;
  final double y;
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;
  final String? type;
  final Map<String, dynamic>? properties;
  final TileModelSprite? sprite;
  final TileModelAnimation? animation;
  final List<CollisionArea>? collisions;

  TileModel({
    required this.x,
    required this.y,
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
    this.type,
    this.properties,
    this.sprite,
    this.animation,
    this.collisions,
  });

  Offset get center => Offset(x + (width / 2.0), y + (height / 2.0));
}
