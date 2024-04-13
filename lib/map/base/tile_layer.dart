import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';
import 'package:bonfire/tiled/builder/tiled_world_builder.dart';
import 'package:bonfire/util/quadtree.dart' as tree;

class TileLayer {
  final String id;
  final List<TileModel> _tiles;
  final String? name;
  final String? layerClass;
  double _opacity;
  final Map<String, dynamic>? properties;
  final Vector2 position;
  GameMap? _gameMap;
  bool _isVisible = true;
  double _tileSize = 0.0;
  Vector2 _size = Vector2.zero();

  Vector2? _lastGameSize;
  Vector2? _lastScreenSize;

  Vector2 get size => _size;
  double get tileSize => _tileSize;
  tree.QuadTree<TileModel>? _quadTree;

  double get left => (position.x * size.x);
  double get right => (position.x * size.x) + size.x;
  double get top => (position.y * size.y);
  double get bottom => (position.y * size.y) + size.y;

  bool get isVisible => _isVisible;

  set isVisible(bool value) {
    _isVisible = value;
    _gameMap?.refreshMap();
  }

  set opacity(double value) {
    _opacity = value;
    _gameMap?.refreshMap();
  }

  TileLayer({
    required this.id,
    required List<TileModel> tiles,
    Vector2? position,
    bool visible = true,
    this.name,
    this.layerClass,
    double opacity = 1,
    this.properties,
  })  : _tiles = tiles,
        position = position ?? Vector2.zero(),
        _isVisible = visible,
        _opacity = opacity {
    _updateSizeAndPosition();
  }

  void _updateSizeAndPosition() {
    if (_tiles.isNotEmpty) {
      _tileSize = _tiles.first.width;

      double w = _tiles.first.right;
      double h = _tiles.first.bottom;

      for (var tile in _tiles) {
        if (tile.right > w) w = tile.right;
        if (tile.bottom > h) h = tile.bottom;
      }
      _size = Vector2(w, h);
    }
  }

  void initLayer(Vector2 gameSize, Vector2 screenSize, GameMap map) {
    _gameMap = map;
    _createQuadTree(gameSize, screenSize);
  }

  void _createQuadTree(
    Vector2 mapSize,
    Vector2 screenSize, {
    bool force = false,
  }) {
    if (_lastGameSize == mapSize && !force) return;
    _lastGameSize = mapSize.clone();
    _lastScreenSize = screenSize.clone();
    Vector2 treeSize = Vector2(
      mapSize.x / tileSize,
      mapSize.y / tileSize,
    );
    int maxItems = 100;
    final minScreen = min(screenSize.x, screenSize.y);
    maxItems = ((minScreen / tileSize) / 2).ceil();
    _quadTree = tree.QuadTree(
      0,
      0,
      treeSize.x,
      treeSize.y,
      maxItems: maxItems,
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
      _createQuadTree(_lastGameSize!, _lastScreenSize!, force: true);
    }
    _gameMap?.refreshMap();
  }

  void addTile(TileModel tile) {
    _tiles.add(tile);
    _updateSizeAndPosition();
    _quadTree?.insert(
      tile,
      Point(tile.x, tile.y),
      id: tile.id,
    );
    _gameMap?.refreshMap();
  }

  void removeTile(String id) {
    try {
      _tiles.removeWhere((element) => element.id == id);
      _quadTree?.removeById(id);
      _updateSizeAndPosition();
      _gameMap?.refreshMap();
    } catch (e) {
      // ignore: avoid_print
      print('Not found visible tile with $id id');
    }
  }

  List<TileModel> getTilesInRect(Rect rect) {
    if (!_isVisible || _quadTree == null) {
      return [];
    }

    return _quadTree!.query(
      rect.getRectangleByTileSize(_tileSize),
    );
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

  factory TileLayer.fromTileModel(LayerModel e) {
    return TileLayer(
      id: e.id.toString(),
      visible: e.visible,
      tiles: e.tiles,
      position: e.position,
      layerClass: e.layerClass,
      name: e.name,
      opacity: e.opacity,
      properties: e.properties,
    );
  }
}
