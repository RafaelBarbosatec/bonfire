import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/map/map_assets_manager.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/map/tile/tile_with_collision.dart';
import 'package:bonfire/util/controlled_update_animation.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

class TileModelSprite {
  final String path;
  final Vector2 position;
  final Vector2 size;

  TileModelSprite({
    required this.path,
    Vector2? position,
    Vector2? size,
  })  : this.position = position ?? Vector2.zero(),
        this.size = size ?? Vector2.zero();

  Sprite getSprite() {
    return MapAssetsManager.getSprite(
      path,
      position,
      size,
    );
  }

  Future<Sprite> getFutureSprite() {
    return MapAssetsManager.getFutureSprite(
      path,
      position: position,
      size: size,
    );
  }

  factory TileModelSprite.fromMap(Map<String, dynamic> map) {
    return new TileModelSprite(
      path: map['path'],
      position: Vector2(map['column'], map['row']),
      size: Vector2(map['width'], map['height']),
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'path': this.path,
      'row': this.position.y,
      'column': this.position.x,
      'width': this.size.x,
      'height': this.size.y,
    } as Map<String, dynamic>;
  }
}

class TileModelAnimation {
  final double stepTime;
  final List<TileModelSprite> frames;

  TileModelAnimation({
    required this.stepTime,
    required this.frames,
  });

  ControlledUpdateAnimation getSpriteControlledAnimation() {
    return MapAssetsManager.getSpriteAnimation(frames, stepTime);
  }

  Future<SpriteAnimation> getFutureSpriteAnimation() {
    return MapAssetsManager.getFutureSpriteAnimation(frames, stepTime);
  }

  factory TileModelAnimation.fromMap(Map<String, dynamic> map) {
    return new TileModelAnimation(
      stepTime: map['stepTime'],
      frames: map['frames'] != null
          ? (map['frames'] as List).map((e) {
              return TileModelSprite.fromMap(e);
            }).toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'stepTime': this.stepTime,
      'frames': this.frames.map((e) => e.toMap()).toList(),
    } as Map<String, dynamic>;
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
  final double angle;
  final bool isFlipVertical;
  final bool isFlipHorizontal;
  final Color? color;
  String id = '';

  Offset center = Offset.zero;

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
    this.color,
    this.animation,
    this.collisions,
    this.angle = 0,
    this.isFlipVertical = false,
    this.isFlipHorizontal = false,
  }) {
    center = Offset(
      (x * width) + (width / 2.0),
      (y * height) + (height / 2.0),
    );
    id = '$x/$y:${DateTime.now().microsecondsSinceEpoch}';
  }
  double get left => (x * width);
  double get right => (x * width) + width;
  double get top => (y * height);
  double get bottom => (y * height) + height;

  Tile getTile(BonfireGameInterface gameRef) {
    if (animation == null) {
      if (collisions?.isNotEmpty == true) {
        final tile = TileWithCollision.fromSprite(
          sprite: sprite?.getSprite(),
          position: Vector2(x, y),
          size: Vector2(width, height),
          offsetX: offsetX,
          offsetY: offsetY,
          collisions: collisions,
          type: type,
          properties: properties,
          color: color,
        );
        tile.angle = angle;
        tile.isFlipHorizontal = isFlipHorizontal;
        tile.isFlipVertical = isFlipVertical;

        tile.gameRef = gameRef;
        tile.id = id;

        return tile;
      } else {
        final tile = Tile.fromSprite(
          sprite: sprite?.getSprite(),
          position: Vector2(x, y),
          size: Vector2(width, height),
          offsetX: offsetX,
          offsetY: offsetY,
          type: type,
          properties: properties,
          color: color,
        );
        tile.angle = angle;
        tile.isFlipHorizontal = isFlipHorizontal;
        tile.isFlipVertical = isFlipVertical;

        tile.gameRef = gameRef;
        tile.id = id;

        return tile;
      }
    } else {
      if (collisions?.isNotEmpty == true) {
        ControlledUpdateAnimation animationControlled =
            animation!.getSpriteControlledAnimation();
        final tile = TileWithCollision.withAnimation(
          animation: animationControlled,
          position: Vector2(x, y),
          size: Vector2(width, height),
          offsetX: offsetX,
          offsetY: offsetY,
          collisions: collisions,
          type: type,
          properties: properties,
        );
        tile.angle = angle;
        tile.isFlipHorizontal = isFlipHorizontal;
        tile.isFlipVertical = isFlipVertical;

        tile.gameRef = gameRef;
        tile.id = id;
        tile.onLoad();

        return tile;
      } else {
        ControlledUpdateAnimation animationControlled =
            animation!.getSpriteControlledAnimation();
        final tile = Tile.fromAnimation(
          animation: animationControlled,
          position: Vector2(x, y),
          size: Vector2(width, height),
          offsetX: offsetX,
          offsetY: offsetY,
          type: type,
          properties: properties,
        );
        tile.angle = angle;
        tile.isFlipHorizontal = isFlipHorizontal;
        tile.isFlipVertical = isFlipVertical;

        tile.gameRef = gameRef;
        tile.id = id;
        tile.onLoad();

        return tile;
      }
    }
  }

  factory TileModel.fromMap(Map<String, dynamic> map) {
    return new TileModel(
      x: map['x'],
      y: map['y'],
      offsetX: map['offsetX'] ?? 0,
      offsetY: map['offsetY'] ?? 0,
      width: map['width'],
      height: map['height'],
      type: map['type'] as String?,
      properties: map['properties'] as Map<String, dynamic>?,
      sprite:
          map['sprite'] == null ? null : TileModelSprite.fromMap(map['sprite']),
      animation: map['animation'] == null
          ? null
          : TileModelAnimation.fromMap(map['animation']),
      collisions: map['collisions'] == null
          ? null
          : (map['collisions'] as List).map((e) {
              return CollisionArea.fromMap(e);
            }).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'x': this.x,
      'y': this.y,
      'offsetX': this.offsetX,
      'offsetY': this.offsetY,
      'width': this.width,
      'height': this.height,
      'type': this.type,
      'properties': this.properties,
      'sprite': this.sprite?.toMap(),
      'animation': this.animation?.toMap(),
      'collisions': this.collisions?.map((e) {
        return e.toMap();
      }).toList(),
    } as Map<String, dynamic>;
  }
}
