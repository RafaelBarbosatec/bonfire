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

  static TerrainSpriteSheet create(String path, Vector2 size) {
    return TerrainSpriteSheet(
      left: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 0,
        y: 1,
      ),
      topLeft: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 0,
        y: 0,
      ),
      bottomLeft: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 0,
        y: 2,
      ),
      right: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 2,
        y: 1,
      ),
      topRight: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 2,
        y: 0,
      ),
      bottomRight: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 2,
        y: 2,
      ),
      top: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 1,
        y: 0,
      ),
      bottom: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 1,
        y: 2,
      ),
      invertedTopLeft: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 3,
        y: 0,
      ),
      invertedTopRight: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 5,
        y: 0,
      ),
      invertedBottomRight: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 5,
        y: 2,
      ),
      invertedBottomLeft: TileModelSprite(
        path: path,
        height: size.y,
        width: size.x,
        x: 3,
        y: 2,
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
  final List<double> spriteRandom;
  final String? type;
  final Map<String, dynamic>? properties;
  final List<CollisionArea>? collisions;
  final bool collisionOnlyCloseCorners;
  List<_RandomRange> _rangeRandom = [];

  MapTerrain({
    required this.value,
    required this.sprites,
    this.spriteRandom = const [],
    this.type,
    this.properties,
    this.collisions,
    this.collisionOnlyCloseCorners = false,
  }) {
    int last = 0;
    spriteRandom.forEach((element) {
      final value = (element * 100).toInt();
      _rangeRandom.add(_RandomRange(last, (last + value)));
      last += value;
    });
  }

  int inRange(int value) {
    int index = _rangeRandom.indexWhere((element) => element.inRange(value));
    return index == -1 ? 0 : index;
  }

  int get maxRandomValue => _rangeRandom.last.end;
}

class MapTerrainCorners extends MapTerrain {
  final double? to;
  final TerrainSpriteSheet spriteSheet;

  MapTerrainCorners({
    required double value,
    required this.to,
    required this.spriteSheet,
  }) : super(value: value, sprites: []);
}
