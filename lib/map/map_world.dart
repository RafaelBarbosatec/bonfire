import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';
import 'package:bonfire/util/quadtree.dart';
import 'package:flutter/material.dart';

class MapWorld extends MapGame {
  static const COUNT_LOT = 2;
  int countBuildTileLot = 100;
  Vector2 lastCamera = Vector2.zero();
  double lastMinorZoom = 1.0;
  Vector2? lastSizeScreen;
  List<ObjectCollision> _tilesCollisions = List.empty(growable: true);
  List<ObjectCollision> _tilesVisibleCollisions = List.empty();
  List<TileModel> _tilesToAdd = [];
  List<Tile> _tilesToRemove = [];
  Set<String> _visibleSet = Set();
  bool _buildingTiles = false;
  bool _updateMapSize = true;
  bool _updateStartPosition = true;
  double tileSize = 0.0;
  Vector2 _griSize = Vector2.zero();
  Size _mapSize = Size.zero;
  Vector2 _mapStartPosition = Vector2.zero();

  List<Offset> _linePath = [];
  Paint _paintPath = Paint()
    ..color = Colors.lightBlueAccent.withOpacity(0.8)
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  QuadTree<TileModel>? quadTree;

  MapWorld(
    List<TileModel> tiles, {
    double tileSizeToUpdate = 0,
  }) : super(
          tiles,
          tileSizeToUpdate: tileSizeToUpdate,
        );

  @override
  void render(Canvas canvas) {
    for (Tile tile in childrenTiles) {
      tile.renderTree(canvas);
    }
    _drawPathLine(canvas);
    super.render(canvas);
  }

  @override
  // ignore: must_call_super
  void update(double dt) {
    for (Tile tile in childrenTiles) {
      tile.update(dt);
      if (tile.isRemoving) {
        _tilesToRemove.add(tile);
      }
    }
    if (!_buildingTiles && _checkNeedUpdateTiles()) {
      _buildingTiles = true;
      scheduleMicrotask(_searchTilesToRender);
    }
    _verifyRemoveTileOfWord();
  }

  void _searchTilesToRender() {
    final rectCamera = gameRef.camera.cameraRectWithSpacing;

    final visibleTileModel = quadTree?.query(
          rectCamera.getRectangleByTileSize(tileSize),
        ) ??
        [];

    _tilesToAdd = visibleTileModel.where((element) {
      return !_visibleSet.contains(element.id);
    }).toList();

    _visibleSet = visibleTileModel.map((e) => e.id).toSet();

    childrenTiles.removeWhere((element) {
      return !_visibleSet.contains((element).id);
    });

    childrenTiles.addAll(_buildTiles(_tilesToAdd));

    _findVisibleCollisions();

    _buildingTiles = false;
  }

  @override
  Iterable<Tile> getRendered() {
    return childrenTiles;
  }

  @override
  Iterable<ObjectCollision> getCollisionsRendered() {
    return _tilesVisibleCollisions;
  }

  @override
  Iterable<ObjectCollision> getCollisions() {
    return _tilesCollisions;
  }

  @override
  void onGameResize(Vector2 size) {
    if (isLoaded) {
      _createQuadTree(size);
    }
    super.onGameResize(size);
  }

  void _createQuadTree(Vector2 size, {bool isUpdate = false}) {
    if (lastSizeScreen == size) return;
    lastSizeScreen = size.clone();

    if (isUpdate) {
      lastCamera = Vector2.zero();
      lastMinorZoom = gameRef.camera.zoom;
      _updateMapSize = true;
      _updateStartPosition = true;
    }

    tileSize = tiles.first.width;

    final mapSize = getMapSize();

    _griSize = Vector2(
      (mapSize.width.ceil() / tileSize).ceilToDouble(),
      (mapSize.height.ceil() / tileSize).ceilToDouble(),
    );

    if (tileSizeToUpdate == 0) {
      tileSizeToUpdate = (tileSize * 4).ceilToDouble();
    }
    gameRef.camera.updateSpacingVisibleMap(tileSizeToUpdate * 1.4);

    _getTileCollisions();

    if (tiles.isNotEmpty) {
      int minSize = min(size.x, size.y).ceil();
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
    this.tiles = map;
    await Future.forEach<TileModel>(tiles, _loadTile);
    _createQuadTree(gameRef.size, isUpdate: true);
  }

  @override
  Size getMapSize() {
    if (_updateMapSize && tiles.isNotEmpty) {
      double height = 0;
      double width = 0;

      this.tiles.forEach((tile) {
        if (tile.right > width) width = tile.right;
        if (tile.bottom > height) height = tile.bottom;
      });
      _updateMapSize = false;
      return _mapSize = Size(width, height);
    }

    return _mapSize;
  }

  Vector2 getGridSize() => _griSize;

  @override
  Vector2 getStartPosition() {
    if (_updateStartPosition && this.tiles.isNotEmpty) {
      double x = this.tiles.first.left;
      double y = this.tiles.first.top;

      this.tiles.forEach((tile) {
        if (tile.left < x) x = tile.left;
        if (tile.top < y) y = tile.top;
      });
      _updateStartPosition = false;
      return _mapStartPosition = Vector2(x, y);
    } else {
      return _mapStartPosition;
    }
  }

  @override
  void setLinePath(List<Offset> path, Color color, double strokeWidth) {
    _paintPath.color = color;
    _paintPath.strokeWidth = strokeWidth;
    _linePath = path;
    super.setLinePath(path, color, strokeWidth);
  }

  void _drawPathLine(Canvas canvas) {
    if (_linePath.isNotEmpty) {
      _paintPath.style = PaintingStyle.stroke;
      final path = Path()..moveTo(_linePath.first.dx, _linePath.first.dy);
      for (var i = 1; i < _linePath.length; i++) {
        path.lineTo(_linePath[i].dx, _linePath[i].dy);
      }
      canvas.drawPath(path, _paintPath);
    }
  }

  void _getTileCollisions() {
    _tilesCollisions.clear();
    final list = tiles.where((element) {
      return element.collisions?.isNotEmpty == true;
    });

    for (var element in list) {
      final collision = element.getTile(gameRef);
      _tilesCollisions.add(collision as ObjectCollision);
    }
  }

  List<Tile> _buildTiles(Iterable<TileModel> visibleTiles) {
    return visibleTiles.map((e) {
      return e.getTile(gameRef);
    }).toList();
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    await Future.forEach<TileModel>(tiles, _loadTile);
    _createQuadTree(gameRef.size);
    _searchTilesToRender();
  }

  void _verifyRemoveTileOfWord() {
    if (_tilesToRemove.isNotEmpty) {
      for (Tile tile in _tilesToRemove) {
        if (tile.isRemoving) {
          childrenTiles.remove(tile);
          tiles.removeWhere((element) => element.id == tile.id);
          quadTree?.removeById(tile.id);
          if (tile is ObjectCollision) {
            _tilesCollisions.removeWhere((element) {
              return (element as Tile).id == tile.id;
            });
            _tilesVisibleCollisions.removeWhere((element) {
              return (element as Tile).id == tile.id;
            });
          }
        }
      }
    }
    _tilesToRemove.clear();
  }

  @override
  Future addTile(TileModel tileModel) async {
    await _loadTile(tileModel);
    final tile = tileModel.getTile(gameRef);
    await tile.onLoad();
    tiles.add(tileModel);
    childrenTiles.add(tile);
    quadTree?.insert(
      tileModel,
      Point(tileModel.x, tileModel.y),
      id: tileModel.id,
    );

    if (tile is ObjectCollision) {
      _tilesCollisions.add(tile as ObjectCollision);
      _findVisibleCollisions();
    }

    _updateMapSize = true;
    _updateStartPosition = true;
  }

  @override
  void removeTile(String id) {
    try {
      childrenTiles
          .firstWhere((element) => (element).id == id)
          .removeFromParent();
    } catch (e) {
      print('Not found visible tile with $id id');
    }
    _updateMapSize = true;
    _updateStartPosition = true;
  }

  void _findVisibleCollisions() {
    _tilesVisibleCollisions =
        childrenTiles.whereType<ObjectCollision>().toList();
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
