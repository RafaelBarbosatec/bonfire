import 'dart:math';

import 'package:bonfire/bonfire.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 01/06/22

final Random _random = Random();

class TerrainSpriteSheet {
  final TileSprite left;
  final TileSprite right;
  final TileSprite top;
  final TileSprite topLeft;
  final TileSprite topRight;
  final TileSprite bottom;
  final TileSprite bottomLeft;
  final TileSprite bottomRight;

  final TileSprite invertedTopLeft;
  final TileSprite invertedTopRight;
  final TileSprite invertedBottomLeft;
  final TileSprite invertedBottomRight;

  TerrainSpriteSheet({
    required this.left,
    required this.right,
    required this.top,
    required this.topLeft,
    required this.topRight,
    required this.bottom,
    required this.bottomLeft,
    required this.bottomRight,
    required this.invertedTopLeft,
    required this.invertedTopRight,
    required this.invertedBottomLeft,
    required this.invertedBottomRight,
  });

  factory TerrainSpriteSheet.create({
    required String path,
    required Vector2 tileSize,
    Vector2? position,
  }) {
    return TerrainSpriteSheet(
      left: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(0, 1) + (position ?? Vector2.zero()),
      ),
      topLeft: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(0, 0) + (position ?? Vector2.zero()),
      ),
      bottomLeft: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(0, 2) + (position ?? Vector2.zero()),
      ),
      right: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(2, 1) + (position ?? Vector2.zero()),
      ),
      topRight: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(2, 0) + (position ?? Vector2.zero()),
      ),
      bottomRight: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(2, 2) + (position ?? Vector2.zero()),
      ),
      top: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(1, 0) + (position ?? Vector2.zero()),
      ),
      bottom: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(1, 2) + (position ?? Vector2.zero()),
      ),
      invertedTopLeft: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(3, 0) + (position ?? Vector2.zero()),
      ),
      invertedTopRight: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(4, 0) + (position ?? Vector2.zero()),
      ),
      invertedBottomRight: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(4, 1) + (position ?? Vector2.zero()),
      ),
      invertedBottomLeft: TileSprite(
        path: path,
        size: tileSize,
        position: Vector2(3, 1) + (position ?? Vector2.zero()),
      ),
    );
  }
}

class _RandomRange {
  final int start;
  final int end;

  _RandomRange(this.start, this.end);

  bool inRange(int value) {
    return value > start && value <= end;
  }

  @override
  String toString() {
    return 'RandomRange{start: $start, end: $end}';
  }
}

class MapTerrain {
  final double value;
  final List<TileSprite> sprites;
  final List<double> spritesProportion;
  final String? type;
  final Map<String, dynamic>? properties;
  final List<ShapeHitbox>? Function()? collisionsBuilder;
  final bool collisionOnlyCloseCorners;
  final List<_RandomRange> _rangeProportion = [];

  MapTerrain({
    required this.value,
    required this.sprites,
    this.spritesProportion = const [],
    this.type,
    this.properties,
    this.collisionsBuilder,
    this.collisionOnlyCloseCorners = false,
  }) {
    var last = 0;
    for (final element in spritesProportion) {
      final value = (element * 100).toInt();
      _rangeProportion.add(_RandomRange(last, last + value));
      last += value;
    }
  }

  int inRange(int value) {
    final index = _rangeProportion.indexWhere(
      (element) => element.inRange(value),
    );
    return index == -1 ? 0 : index;
  }

  int get maxRandomValue => _rangeProportion.last.end;

  List<ShapeHitbox>? getCollisionClone({bool checkOnlyClose = false}) {
    return (collisionOnlyCloseCorners && checkOnlyClose)
        ? null
        : collisionsBuilder?.call();
  }

  TileSprite? getSingleSprite() {
    if (sprites.length > 1 && sprites.length == spritesProportion.length) {
      final randomValue = _random.nextInt(maxRandomValue);
      final index = inRange(randomValue);

      return sprites[index];
    } else {
      return sprites.first;
    }
  }
}

class MapTerrainCorners extends MapTerrain {
  final double? to;
  final TerrainSpriteSheet spriteSheet;

  MapTerrainCorners({
    required super.value,
    required this.to,
    required this.spriteSheet,
    super.type,
    super.properties,
    super.collisionsBuilder,
  }) : super(
          sprites: [],
        );
}
