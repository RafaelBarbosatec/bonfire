import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/map/map_assets_manager.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

class TileModelSprite {
  final String path;
  final int row;
  final int column;
  final double width;
  final double height;

  TileModelSprite({
    required this.path,
    this.row = 0,
    this.column = 0,
    this.width = 0,
    this.height = 0,
  });

  Future<Sprite> getSprite() {
    if (row == 0 && column == 0 && width == 0 && height == 0) {
      return Sprite.load(path);
    }
    return MapAssetsManager.getSprite(
      path,
      row,
      column,
      width,
      height,
      fromServer: path.contains('http'),
    );
  }
}

class TileModelAnimation {
  final double stepTime;
  final List<TileModelSprite> frames;

  TileModelAnimation({
    required this.stepTime,
    required this.frames,
  });

  Future<SpriteAnimation> getSpriteAnimation() async {
    List<Sprite> spriteList = [];

    await Future.forEach<TileModelSprite>(frames, (frame) async {
      Sprite sprite = await MapAssetsManager.getSprite(
        frame.path,
        frame.row,
        frame.column,
        frame.width,
        frame.height,
        fromServer: frame.path.contains('http'),
      );
      spriteList.add(sprite);
    });

    return SpriteAnimation.spriteList(
      spriteList,
      stepTime: stepTime,
    );
  }
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
    this.offsetX = 0.0,
    this.offsetY = 0.0,
    required this.width,
    required this.height,
    this.type,
    this.properties,
    this.sprite,
    this.animation,
    this.collisions,
  });

  double get left => (x * width);
  double get right => (x * width) + width;
  double get top => (y * height);
  double get bottom => (y * height) + height;
  Offset get center =>
      Offset((x * width) + (width / 2.0), (y * height) + (height / 2.0));
}
