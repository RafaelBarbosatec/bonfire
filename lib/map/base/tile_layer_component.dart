import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';
import 'package:bonfire/util/quadtree.dart' as tree;

class TileLayerComponent extends PositionComponent with HasPaint, UseShader {
  final int id;
  final String? name;
  final String? layerClass;
  final Map<String, dynamic>? properties;
  List<Tile> _tiles;
  bool _isVisible = true;
  double _tileSize = 0.0;

  Vector2? _lastScreenSize;

  double get tileSize => _tileSize;
  tree.QuadTree<Tile>? _quadTree;

  bool get visible => _isVisible;

  set visible(bool value) {
    _isVisible = value;
    refresh();
  }

  Set<String> _visibleSet = {};

  TileLayerComponent({
    required this.id,
    required List<Tile> tiles,
    super.position,
    bool visible = true,
    this.name,
    this.layerClass,
    double opacity = 1,
    this.properties,
    super.priority,
  })  : _tiles = tiles,
        _isVisible = visible {
    this.opacity = opacity;
    _updateSizeAndPosition();
  }

  void _updateSizeAndPosition() {
    if (_tiles.isNotEmpty) {
      _tileSize = _tiles.first.width;

      var w = _tiles.first.right;
      var h = _tiles.first.bottom;

      for (final tile in _tiles) {
        if (tile.right > w) {
          w = tile.right;
        }
        if (tile.bottom > h) {
          h = tile.bottom;
        }
      }
      size = Vector2(w, h);
    }
  }

  void initLayer(Vector2 gameSize, Vector2 screenSize) {
    if (gameSize.isZero()) {
      return;
    }
    _createQuadTree(gameSize, screenSize);
  }

  void _createQuadTree(
    Vector2 mapSize,
    Vector2 screenSize, {
    bool force = false,
  }) {
    if (_lastScreenSize == screenSize && !force) {
      return;
    }
    _lastScreenSize = screenSize.clone();
    final treeSize = Vector2(
      mapSize.x / tileSize,
      mapSize.y / tileSize,
    );
    var maxItems = 100;
    final minScreen = min(screenSize.x, screenSize.y);
    maxItems = ((minScreen / tileSize) / 2).ceil();
    _quadTree = tree.QuadTree(
      0,
      0,
      treeSize.x,
      treeSize.y,
      maxItems: maxItems,
    );

    for (final tile in _tiles) {
      _quadTree?.insert(
        tile,
        Point(tile.x, tile.y),
        id: tile.id,
      );
    }
  }

  void updateTiles(List<Tile> tiles) {
    _tiles = tiles;
    removeAll(children);
    _quadTree?.clear();
    _updateSizeAndPosition();

    for (final tile in _tiles) {
      _quadTree?.insert(
        tile,
        Point(tile.x, tile.y),
        id: tile.id,
      );
    }
    refresh();
  }

  void addTile(Tile tile) {
    _tiles.add(tile);
    _updateSizeAndPosition();
    _quadTree?.insert(
      tile,
      Point(tile.x, tile.y),
      id: tile.id,
    );
    refresh();
  }

  void removeTile(String id) {
    try {
      _tiles.removeWhere((element) => element.id == id);
      _quadTree?.removeById(id);
      _updateSizeAndPosition();
      refresh();
    } catch (e) {
      // ignore: avoid_print
      print('Not found visible tile with $id id');
    }
  }

  void refresh() {
    _visibleSet.clear();
    removeAll(children);
    onMoveCamera(_lastRectCamera);
  }

  Rect _lastRectCamera = Rect.zero;

  Future<void> onMoveCamera(Rect rectCamera) {
    if (!_isVisible || _quadTree == null) {
      return Future.value();
    }
    _lastRectCamera = rectCamera;

    final visibleTiles = _quadTree!.query(
      rectCamera.getRectangleByTileSize(_tileSize),
    );

    final tilesToAdd = visibleTiles.where((element) {
      return !_visibleSet.contains(element.id);
    }).toList();

    _visibleSet = visibleTiles.map((e) => e.id).toSet();

    removeWhere((tile) => !_visibleSet.contains((tile as TileComponent).id));

    return addAll(_buildTiles(tilesToAdd));
  }

  Iterable<TileComponent> _buildTiles(Iterable<Tile> visibleTiles) {
    return visibleTiles.map((e) {
      return e.getTile();
    });
  }

  Future<void> loadAssets() {
    return Future.forEach(_tiles, _loadTile);
  }

  Future<void> _loadTile(Tile element) async {
    if (element.sprite != null) {
      await MapAssetsManager.loadImage(element.sprite?.path ?? '');
    }
    if (element.animation != null) {
      for (final frame in element.animation?.frames ?? <TileSprite>[]) {
        await MapAssetsManager.loadImage(frame.path);
      }
    }
    return Future.value();
  }

  @override
  Future onLoad() async {
    await loadAssets();
    return super.onLoad();
  }

  Iterable<TileComponent> getRendered() {
    return children.query<TileComponent>();
  }
}
