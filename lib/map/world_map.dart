import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/empty_map.dart';
import 'package:bonfire/util/quadtree.dart' as tree;

class WorldMap extends GameMap {
  Vector2 lastCamera = Vector2.zero();
  double lastMinorZoom = 1.0;
  Vector2? lastSizeScreen;
  Set<String> _visibleSet = {};
  bool _buildingTiles = false;
  Vector2 _mapPosition = Vector2.zero();
  Vector2 _mapSize = Vector2.zero();

  tree.QuadTree<TileModel>? quadTree;

  factory WorldMap.empty({Vector2? size}) {
    return EmptyWorldMap(size: size);
  }

  WorldMap(
    List<TileLayer> tiles, {
    double tileSizeToUpdate = 0,
  }) : super(
          tiles,
          sizeToUpdate: tileSizeToUpdate,
        ) {
    enabledCheckIsVisible = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_buildingTiles && _checkNeedUpdateTiles()) {
      _buildingTiles = true;
      _searchTilesToRender();
    }
  }

  void _searchTilesToRender() {
    final rectCamera = gameRef.camera.cameraRectWithSpacing;

    List<TileModel> visibleTileModel = [];

    for (var layer in layers) {
      if (layer.isVisible) {
        visibleTileModel.addAll(layer.getTilesInRect(rectCamera));
      }
    }

    final tilesToAdd = visibleTileModel.where((element) {
      return !_visibleSet.contains(element.id);
    }).toList();

    _visibleSet = visibleTileModel.map((e) => e.id).toSet();

    removeWhere((tile) => !_visibleSet.contains((tile as Tile).id));

    addAll(_buildTiles(tilesToAdd));

    _buildingTiles = false;
  }

  @override
  Iterable<Tile> getRendered() {
    return children.cast();
  }

  @override
  void onGameResize(Vector2 size) {
    if (isLoaded) {
      _confMap(size);
    }
    super.onGameResize(size);
  }

  @override
  void refreshMap() {
    _searchTilesToRender();
  }

  void _confMap(Vector2 sizeScreen, {bool calculateSize = false}) {
    lastSizeScreen = sizeScreen;
    if (calculateSize) {
      lastCamera = Vector2.zero();
      lastMinorZoom = gameRef.camera.zoom;
      _calculatePositionAndSize();
      for (var layer in layers) {
        layer.initLayer(size, sizeScreen, this);
      }
    }

    if (sizeToUpdate == 0) {
      sizeToUpdate = (tileSize * 4).ceilToDouble();
    }
    gameRef.camera.updateSpacingVisibleMap(sizeToUpdate * 1.5);
  }

  @override
  Future<void> updateLayers(List<TileLayer> layers) async {
    this.layers = layers;
    _confMap(gameRef.size, calculateSize: true);
    await _loadAssets();
    refreshMap();
  }

  void _calculatePositionAndSize() {
    if (layers.isNotEmpty) {
      tileSize = layers.first.tileSize;
      double x = 0;
      double y = 0;

      double w = layers.first.size.x;
      double h = layers.first.size.y;

      for (var layer in layers) {
        if (layer.left < x) x = layer.left;
        if (layer.top < y) y = layer.top;

        if (layer.right > w) w = layer.right;
        if (layer.bottom > h) h = layer.bottom;
      }
      _mapSize = Vector2(w - x, h - y);
      size = Vector2(w, h);
      _mapPosition = Vector2(x, y);

      gameRef.camera.updateBoundsAndZoomFit();
      (gameRef as BonfireGame).configCollision();
    }
  }

  @override
  Vector2 getMapSize() {
    return _mapSize;
  }

  @override
  Vector2 getMapPosition() {
    return _mapPosition;
  }

  List<Tile> _buildTiles(Iterable<TileModel> visibleTiles) {
    return visibleTiles.map((e) {
      return e.getTile();
    }).toList();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _confMap(gameRef.size, calculateSize: true);
    await _loadAssets();
    _searchTilesToRender();
    updateLastCamera(null);
  }

  Future<void> _loadAssets() async {
    return Future.forEach(layers, (element) => element.loadAssets());
  }

  bool _checkNeedUpdateTiles() {
    final camera = _getCameraTileUpdate();
    if (lastCamera != camera || lastMinorZoom != gameRef.camera.zoom) {
      updateLastCamera(camera);

      return true;
    }
    return false;
  }

  void updateLastCamera(Vector2? camera) {
    lastCamera = camera ?? _getCameraTileUpdate();
    lastMinorZoom = gameRef.camera.zoom;
  }

  Vector2 _getCameraTileUpdate() {
    final camera = gameRef.camera;
    return Vector2(
      (camera.position.x / (sizeToUpdate / camera.zoom)).floorToDouble(),
      (camera.position.y / (sizeToUpdate / camera.zoom)).floorToDouble(),
    );
  }

  @override
  Future addLayer(TileLayer layer) async {
    await layer.loadAssets();
    layers.add(layer);
    _confMap(lastSizeScreen!, calculateSize: true);
    refreshMap();
  }

  @override
  void removeLayer(String id) {
    layers.removeWhere((l) => l.id == id);
    _confMap(lastSizeScreen!, calculateSize: true);
    refreshMap();
  }
}
