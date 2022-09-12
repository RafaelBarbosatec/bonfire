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
  final TileModelSprite left;
  final TileModelSprite right;
  final TileModelSprite top;
  final TileModelSprite topLeft;
  final TileModelSprite topRight;
  final TileModelSprite bottom;
  final TileModelSprite bottomLeft;
  final TileModelSprite bottomRight;

  final TileModelSprite invertedTopLeft;
  final TileModelSprite invertedTopRight;
  final TileModelSprite invertedBottomLeft;
  final TileModelSprite invertedBottomRight;

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

  static TerrainSpriteSheet create({
    required String path,
    required Vector2 tileSize,
    Vector2? position,
  }) {
    return TerrainSpriteSheet(
      left: TileModelSprite(
        path: path,
        size: tileSize,
        position: Vector2(0, 1) + (position ?? Vector2.zero()),
      ),
      topLeft: TileModelSprite(
        path: path,
        size: tileSize,
        position: Vector2(0, 0) + (position ?? Vector2.zero()),
      ),
      bottomLeft: TileModelSprite(
        path: path,
        size: tileSize,
        position: Vector2(0, 2) + (position ?? Vector2.zero()),
      ),
      right: TileModelSprite(
        path: path,
        size: tileSize,
        position: Vector2(2, 1) + (position ?? Vector2.zero()),
      ),
      topRight: TileModelSprite(
        path: path,
        size: tileSize,
        position: Vector2(2, 0) + (position ?? Vector2.zero()),
      ),
      bottomRight: TileModelSprite(
        path: path,
        size: tileSize,
        position: Vector2(2, 2) + (position ?? Vector2.zero()),
      ),
      top: TileModelSprite(
        path: path,
        size: tileSize,
        position: Vector2(1, 0) + (position ?? Vector2.zero()),
      ),
      bottom: TileModelSprite(
        path: path,
        size: tileSize,
        position: Vector2(1, 2) + (position ?? Vector2.zero()),
      ),
      invertedTopLeft: TileModelSprite(
        path: path,
        size: tileSize,
        position: Vector2(3, 0) + (position ?? Vector2.zero()),
      ),
      invertedTopRight: TileModelSprite(
        path: path,
        size: tileSize,
        position: Vector2(4, 0) + (position ?? Vector2.zero()),
      ),
      invertedBottomRight: TileModelSprite(
        path: path,
        size: tileSize,
        position: Vector2(4, 1) + (position ?? Vector2.zero()),
      ),
      invertedBottomLeft: TileModelSprite(
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
  final List<TileModelSprite> sprites;
  final List<double> spritesProportion;
  final String? type;
  final Map<String, dynamic>? properties;
  final List<CollisionArea>? collisions;
  final bool collisionOnlyCloseCorners;
  final List<_RandomRange> _rangeProportion = [];

  MapTerrain({
    required this.value,
    required this.sprites,
    this.spritesProportion = const [],
    this.type,
    this.properties,
    this.collisions,
    this.collisionOnlyCloseCorners = false,
  }) {
    int last = 0;
    for (var element in spritesProportion) {
      final value = (element * 100).toInt();
      _rangeProportion.add(_RandomRange(last, (last + value)));
      last += value;
    }
  }

  int inRange(int value) {
    int index = _rangeProportion.indexWhere(
      (element) => element.inRange(value),
    );
    return index == -1 ? 0 : index;
  }

  int get maxRandomValue => _rangeProportion.last.end;

  List<CollisionArea>? getCollisionClone({bool checkOnlyClose = false}) {
    return (collisionOnlyCloseCorners && checkOnlyClose)
        ? null
        : collisions?.map((e) => e.clone()).toList();
  }

  TileModelSprite? getSingleSprite() {
    if (sprites.length > 1 && sprites.length == spritesProportion.length) {
      int randomValue = _random.nextInt(maxRandomValue);
      int index = inRange(randomValue);

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
    required double value,
    required this.to,
    required this.spriteSheet,
    String? type,
    Map<String, dynamic>? properties,
    List<CollisionArea>? collisions,
  }) : super(
          value: value,
          sprites: [],
          type: type,
          properties: properties,
          collisions: collisions,
        );
}
