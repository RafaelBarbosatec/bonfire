import 'dart:math' as math;

import 'package:bonfire/map/base/tile_component.dart';
import 'package:bonfire/map/base/tile_with_collision.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';
import 'package:bonfire/util/controlled_update_animation.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

class TileSprite {
  final String path;
  final Vector2 position;
  final Vector2 size;

  TileSprite({
    required this.path,
    Vector2? position,
    Vector2? size,
  })  : position = position ?? Vector2.zero(),
        size = size ?? Vector2.zero();

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

  factory TileSprite.fromMap(Map<String, dynamic> map) {
    return TileSprite(
      path: map['path'].toString(),
      position: Vector2(
        double.parse(map['column'].toString()),
        double.parse(map['row'].toString()),
      ),
      size: Vector2(
        double.parse(map['width'].toString()),
        double.parse(map['height'].toString()),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'row': position.y,
      'column': position.x,
      'width': size.x,
      'height': size.y,
    };
  }
}

class TilelAnimation {
  final double stepTime;
  final List<TileSprite> frames;

  TilelAnimation({
    required this.stepTime,
    required this.frames,
  });

  ControlledUpdateAnimation getSpriteControlledAnimation() {
    return MapAssetsManager.getSpriteAnimation(frames, stepTime);
  }

  Future<SpriteAnimation> getFutureSpriteAnimation() {
    return MapAssetsManager.getFutureSpriteAnimation(frames, stepTime);
  }

  factory TilelAnimation.fromMap(Map<String, dynamic> map) {
    return TilelAnimation(
      stepTime: double.parse(map['stepTime'].toString()),
      frames: map['frames'] != null
          ? (map['frames'] as List).map((e) {
              return TileSprite.fromMap((e as Map).cast());
            }).toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stepTime': stepTime,
      'frames': frames.map((e) => e.toMap()).toList(),
    };
  }
}

class Tile {
  final double x;
  final double y;
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;
  final double opacity;
  final String? tileClass;
  final Map<String, dynamic>? properties;
  final TileSprite? sprite;
  final TilelAnimation? animation;
  final List<ShapeHitbox>? collisions;
  final double angle;
  final bool isFlipVertical;
  final bool isFlipHorizontal;
  final Color? color;
  String id = '';

  Tile({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
    this.tileClass,
    this.properties,
    this.sprite,
    this.color,
    this.animation,
    this.collisions,
    this.angle = 0,
    this.opacity = 1.0,
    this.isFlipVertical = false,
    this.isFlipHorizontal = false,
  }) {
    id = '$x/$y:${DateTime.now().microsecondsSinceEpoch}';
  }
  double get left => x * width;
  double get right => (x * width) + width;
  double get top => y * height;
  double get bottom => (y * height) + height;

  TileComponent getTile() {
    if (animation == null) {
      if (collisions?.isNotEmpty == true) {
        final tile = TileWithCollision.fromSprite(
          sprite: sprite?.getSprite(),
          position: Vector2(x, y),
          size: Vector2(width, height),
          offsetX: offsetX,
          offsetY: offsetY,
          collisions: collisions,
          tileClass: tileClass,
          properties: properties,
          color: color,
        );
        _setOtherParams(tile);
        return tile;
      } else {
        final tile = TileComponent.fromSprite(
          sprite: sprite?.getSprite(),
          position: Vector2(x, y),
          size: Vector2(width, height),
          offsetX: offsetX,
          offsetY: offsetY,
          tileClass: tileClass,
          properties: properties,
          color: color,
        );
        _setOtherParams(tile);

        return tile;
      }
    } else {
      if (collisions?.isNotEmpty == true) {
        final animationControlled = animation!.getSpriteControlledAnimation();
        final tile = TileWithCollision.withAnimation(
          animation: animationControlled,
          position: Vector2(x, y),
          size: Vector2(width, height),
          offsetX: offsetX,
          offsetY: offsetY,
          collisions: collisions,
          tileClass: tileClass,
          properties: properties,
        );
        _setOtherParams(tile);

        return tile;
      } else {
        final animationControlled = animation!.getSpriteControlledAnimation();
        final tile = TileComponent.fromAnimation(
          animation: animationControlled,
          position: Vector2(x, y),
          size: Vector2(width, height),
          offsetX: offsetX,
          offsetY: offsetY,
          tileClass: tileClass,
          properties: properties,
        );
        _setOtherParams(tile);

        return tile;
      }
    }
  }

  void _setOtherParams(TileComponent tile) {
    tile.id = id;
    tile.angle = angle;
    tile.opacity = opacity;
    if (isFlipHorizontal) {
      tile.flipHorizontallyAroundCenter();
    }
    if (isFlipVertical) {
      tile.flipVerticallyAroundCenter();
    }

    // Needs to be debugged with different anchors. Works for default.
    // tile.anchor = Anchor.topCenter;
    _translateTileAngle(tile); // Force tile to be in it's box after rotation
  }

  void _translateTileAngle(TileComponent tile) {
    // Depending or where the rotated object is - move it to positive coordinates:

    final angle = tile.angle;
    final sin = math.sin(angle);
    final cos = math.cos(angle);
    if (tile.anchor.x != 0.5) {
      final delta =
          (1 - 2 * tile.anchor.x) * tile.width * tile.transform.scale.x;
      if (cos < 0.9) {
        tile.transform.x -= delta * cos;
      }
      if (sin < 0.9) {
        tile.transform.y -= delta * sin;
      }
    }

    if (tile.anchor.y != 0.5) {
      final delta =
          (1 - 2 * tile.anchor.y) * tile.height * tile.transform.scale.y;
      if (sin > 0.9) {
        tile.transform.x += delta * sin;
      }
      if (cos < 0.9) {
        tile.transform.y -= delta * cos;
      }
    }
  }
}
