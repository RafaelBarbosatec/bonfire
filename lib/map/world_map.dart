import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';
import 'package:bonfire/util/quadtree.dart';

class WorldMap extends GameMap {
  Vector2 lastCamera = Vector2.zero();
  double lastMinorZoom = 1.0;
  Vector2? lastSizeScreen;
  Set<String> _visibleSet = {};
  bool _buildingTiles = false;
  double tileSize = 0.0;
  Vector2 _griSize = Vector2.zero();
  Vector2 _mapStartPosition = Vector2.zero();

  QuadTree<TileModel>? quadTree;

  WorldMap(
    List<TileModel> tiles, {
    double tileSizeToUpdate = 0,
  }) : super(
          tiles,
          tileSizeToUpdate: tileSizeToUpdate,
        ) {
    enabledCheckIsVisible = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_buildingTiles && _checkNeedUpdateTiles()) {
      _buildingTiles = true;
      scheduleMicrotask(_searchTilesToRender);
    }
  }

  void _searchTilesToRender() {
    final rectCamera = gameRef.camera.cameraRectWithSpacing;

    final visibleTileModel = quadTree?.query(
          rectCamera.getRectangleByTileSize(tileSize),
        ) ??
        [];

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
      _createQuadTree(size);
    }
    super.onGameResize(size);
  }

  void _createQuadTree(Vector2 sizeScreen, {bool isUpdate = false}) {
    if (lastSizeScreen == sizeScreen) return;
    lastSizeScreen = size.clone();

    if (isUpdate) {
      lastCamera = Vector2.zero();
      lastMinorZoom = gameRef.camera.zoom;
      _calculateStartPosition();
    }

    tileSize = tiles.first.width;

    _griSize = Vector2(
      (size.x.ceil() / tileSize).ceilToDouble(),
      (size.y.ceil() / tileSize).ceilToDouble(),
    );

    if (tileSizeToUpdate == 0) {
      tileSizeToUpdate = (tileSize * 4).ceilToDouble();
    }
    gameRef.camera.updateSpacingVisibleMap(tileSizeToUpdate * 1.5);

    if (tiles.isNotEmpty) {
      int minSize = min(sizeScreen.x, sizeScreen.y).ceil();
      int maxItems = ((minSize / 2) / tileSize).ceil();
      maxItems *= maxItems;
      quadTree = QuadTree(
        0,
        0,
        _griSize.x,
        _griSize.y,
        maxItems: maxItems,
      );

      for (var tile in tiles) {
        quadTree?.insert(tile, Point(tile.x, tile.y), id: tile.id);
      }
    }
  }

  @override
  Future<void> updateTiles(List<TileModel> map) async {
    lastSizeScreen = null;
    tiles = map;
    size = _calculateMapSize();
    await Future.forEach<TileModel>(tiles, _loadTile);
    _createQuadTree(gameRef.size, isUpdate: true);
  }

  Vector2 _calculateMapSize() {
    if (tiles.isNotEmpty) {
      double height = 0;
      double width = 0;

      for (var tile in tiles) {
        if (tile.right > width) width = tile.right;
        if (tile.bottom > height) height = tile.bottom;
      }
      return Vector2(width, height);
    }
    return size;
  }

  void _calculateStartPosition() {
    if (tiles.isNotEmpty) {
      double x = tiles.first.left;
      double y = tiles.first.top;

      for (var tile in tiles) {
        if (tile.left < x) x = tile.left;
        if (tile.top < y) y = tile.top;
      }
      _mapStartPosition = Vector2(x, y);
    }
  }

  @override
  Vector2 getGridSize() => _griSize;

  @override
  Vector2 getStartPosition() {
    return _mapStartPosition;
  }

  List<Tile> _buildTiles(Iterable<TileModel> visibleTiles) {
    return visibleTiles.map((e) {
      return e.getTile();
    }).toList();
  }

  @override
  Future<void>? onLoad() async {
    _calculateStartPosition();
    size = _calculateMapSize();
    await super.onLoad();
    await Future.forEach<TileModel>(tiles, _loadTile);
    _createQuadTree(gameRef.size);
    _searchTilesToRender();
  }

  @override
  Future addTile(TileModel tileModel) async {
    await _loadTile(tileModel);
    tiles.add(tileModel);
    add(tileModel.getTile());
    quadTree?.insert(
      tileModel,
      Point(tileModel.x, tileModel.y),
      id: tileModel.id,
    );

    _calculateStartPosition();
    size = _calculateMapSize();
  }

  @override
  void removeTile(String id) {
    try {
      children
          .firstWhere((element) => (element as Tile).id == id)
          .removeFromParent();
      tiles.removeWhere((element) => element.id == id);
      quadTree?.removeById(id);
      _calculateStartPosition();
      size = _calculateMapSize();
    } catch (e) {
      // ignore: avoid_print
      print('Not found visible tile with $id id');
    }
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

  bool _checkNeedUpdateTiles() {
    final camera = _getCameraTileUpdate();
    if (lastCamera != camera || lastMinorZoom != gameRef.camera.zoom) {
      lastCamera = camera;
      lastMinorZoom = gameRef.camera.zoom;

      return true;
    }
    return false;
  }

  Vector2 _getCameraTileUpdate() {
    return Vector2(
      (gameRef.camera.position.x / tileSizeToUpdate).floorToDouble(),
      (gameRef.camera.position.y / tileSizeToUpdate).floorToDouble(),
    );
  }
}
