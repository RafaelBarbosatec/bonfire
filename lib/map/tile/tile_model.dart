import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/map/map_assets_manager.dart';
import 'package:bonfire/util/controlled_update_animation.dart';
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

  bool get inCache => MapAssetsManager.inSpriteCache('$path/$row/$column');
  Future<Sprite> getFutureSprite() {
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

  Sprite getSprite() {
    return MapAssetsManager.getSpriteCache('$path/$row/$column');
  }
}

class TileModelAnimation {
  final double stepTime;
  final List<TileModelSprite> frames;

  TileModelAnimation({
    required this.stepTime,
    required this.frames,
  });

  bool get inCache => MapAssetsManager.inSpriteAnimationCache(key());

  Future<ControlledUpdateAnimation> getFutureControlledAnimation() async {
    return MapAssetsManager.getSpriteAnimation(frames, stepTime);
  }

  Future<SpriteAnimation> getFutureSpriteAnimation() async {
    final a = await MapAssetsManager.getSpriteAnimation(frames, stepTime);
    return a.animation!;
  }

  ControlledUpdateAnimation getSpriteAnimation() {
    return MapAssetsManager.getSpriteAnimationCache(key());
  }

  String key() {
    String key = '';
    frames.forEach((element) {
      key += '${element.path}${element.row}${element.column}';
    });
    return key;
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

  String get id => '$x/$y';
  double get left => (x * width);
  double get right => (x * width) + width;
  double get top => (y * height);
  double get bottom => (y * height) + height;
  Offset get center =>
      Offset((x * width) + (width / 2.0), (y * height) + (height / 2.0));
}
