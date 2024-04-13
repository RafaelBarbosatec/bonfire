import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';
import 'package:bonfire/util/quadtree.dart' as tree;

class TileLayer {
  final String id;
  final List<TileModel> _tiles;
  bool isVisible = true;
  double _tileSize = 0.0;
  Vector2 _size = Vector2.zero();
  Vector2 _position = Vector2.zero();
  Vector2? _lastGameSize;

  Vector2 get size => _size;
  Vector2 get position => _position;
  double get tileSize => _tileSize;
  tree.QuadTree<TileModel>? _quadTree;

  double get left => (position.x * size.x);
  double get right => (position.x * size.x) + size.x;
  double get top => (position.y * size.y);
  double get bottom => (position.y * size.y) + size.y;

  TileLayer({
    required this.id,
    required List<TileModel> tiles,
    this.isVisible = true,
  }) : _tiles = tiles {
    _updateSizeAndPosition();
  }

  void _updateSizeAndPosition() {
    if (_tiles.isNotEmpty) {
      _tileSize = _tiles.first.width;

      double x = 0;
      double y = 0;

      double w = _tiles.first.right;
      double h = _tiles.first.bottom;

      for (var tile in _tiles) {
        if (tile.left < x) x = tile.left;
        if (tile.top < y) y = tile.top;
        if (tile.right > w) w = tile.right;
        if (tile.bottom > h) h = tile.bottom;
      }
      _position = Vector2(x, y);
      _size = Vector2(w, h);
    }
  }

  void onGameResize(Vector2 gameSize) {
    _createQuadTree(gameSize);
  }

  void _createQuadTree(Vector2 mapSize, {bool force = false}) {
    if (_lastGameSize == mapSize && !force) return;
    _lastGameSize = mapSize.clone();
    Vector2 treeSize = Vector2(
      mapSize.x/tileSize,
      mapSize.y/tileSize,
    );

    _quadTree = tree.QuadTree(
      0,
      0,
      treeSize.x,
      treeSize.y,
    );

    for (var tile in _tiles) {
      _quadTree?.insert(
        tile,
        Point(tile.x, tile.y),
        id: tile.id,
      );
    }
  }

  void updateTiles(List<TileModel> tiles) {
    _tiles;
    _updateSizeAndPosition();
    if (_lastGameSize != null) {
      _createQuadTree(_lastGameSize!, force: true);
    }
  }

  void addTile(TileModel tile) {
    _tiles.add(tile);
    _updateSizeAndPosition();
    _quadTree?.insert(
      tile,
      Point(tile.x, tile.y),
      id: tile.id,
    );
  }

  void removeTile(String id) {
    try {
      _tiles.removeWhere((element) => element.id == id);
      _quadTree?.removeById(id);
      _updateSizeAndPosition();
    } catch (e) {
      // ignore: avoid_print
      print('Not found visible tile with $id id');
    }
  }

  List<TileModel> getTilesInRect(Rect rect) {
    if (!isVisible || _quadTree == null) {
      return [];
    }
    final result = _quadTree!.query(rect.getRectangleByTileSize(_tileSize));
    print('resultado:${result.length}');
    return result;
  }

  Future<void> loadAssets() {
    return Future.forEach(_tiles, _loadTile);
  }

  Future<void> _loadTile(TileModel element) async {
    if (element.sprite != null) {
      await MapAssetsManager.loadImage((element.sprite?.path ?? ''));
    }
    if (element.animation != null) {
      for (var frame in (element.animation?.frames ?? [])) {
        await MapAssetsManager.loadImage(frame.path);
      }
    }
    return Future.value();
  }
}
