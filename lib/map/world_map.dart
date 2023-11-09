import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';
import 'package:bonfire/util/quadtree.dart' as tree;

class WorldMap extends GameMap {
  Vector2 lastCamera = Vector2.zero();
  double lastMinorZoom = 1.0;
  Vector2? lastSizeScreen;
  Set<String> _visibleSet = {};
  bool _buildingTiles = false;
  Vector2 _griSize = Vector2.zero();
  Vector2 _mapPosition = Vector2.zero();
  Vector2 _mapSize = Vector2.zero();

  tree.QuadTree<TileModel>? quadTree;

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
      _calculatePositionAndSize();
    }

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
      quadTree = tree.QuadTree(
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
    _calculatePositionAndSize();
    await Future.forEach<TileModel>(tiles, _loadTile);
    _createQuadTree(gameRef.size, isUpdate: true);
  }

  void _calculatePositionAndSize() {
    if (tiles.isNotEmpty) {
      tileSize = tiles.first.width;
      double x = tiles.first.left;
      double y = tiles.first.top;

      double w = tiles.first.right;
      double h = tiles.first.bottom;

      for (var tile in tiles) {
        if (tile.left < x) x = tile.left;
        if (tile.top < y) y = tile.top;

        if (tile.right > w) w = tile.right;
        if (tile.bottom > h) h = tile.bottom;
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
  Future<void>? onLoad() async {
    _calculatePositionAndSize();
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

    _calculatePositionAndSize();
  }

  @override
  void removeTile(String id) {
    try {
      children
          .firstWhere((element) => (element as Tile).id == id)
          .removeFromParent();
      tiles.removeWhere((element) => element.id == id);
      quadTree?.removeById(id);
      _calculatePositionAndSize();
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
    final camera = gameRef.camera;
    return Vector2(
      (camera.position.x / (tileSizeToUpdate / camera.zoom)).floorToDouble(),
      (camera.position.y / (tileSizeToUpdate / camera.zoom)).floorToDouble(),
    );
  }
}
