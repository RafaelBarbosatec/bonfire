import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/quadtree.dart';
import 'package:flutter/material.dart';

import 'map_assets_manager.dart';

class MapWorld extends MapGame {
  static const COUNT_LOT = 2;
  int countBuildTileLot = 100;
  Vector2 lastCamera = Vector2.zero();
  double lastMinorZoom = 1.0;
  Vector2? lastSizeScreen;
  List<ObjectCollision> _tilesCollisions = List.empty();
  List<ObjectCollision> _tilesVisibleCollisions = List.empty();
  List<TileModel> _tilesToAdd = [];
  List<Tile> _tilesToRemove = [];
  Set<String> _visibleSet = Set();
  bool _buildingTiles = false;
  double tileSize = 0.0;

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
      if (tile.shouldRemove) {
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
      _verifyMaxTopAndLeft(size);
    }
    super.onGameResize(size);
  }

  void _verifyMaxTopAndLeft(Vector2 size, {bool isUpdate = false}) {
    if (lastSizeScreen == size) return;
    lastSizeScreen = size.clone();

    if (isUpdate) {
      lastCamera = Vector2.zero();
      lastMinorZoom = 1.0;
    }

    tileSize = tiles.first.width;

    mapSize = getMapSize();
    mapStartPosition = getStartPosition();

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
        ((mapSize?.width ?? 0).ceil() / tileSize).ceil(),
        ((mapSize?.height ?? 0).ceil() / tileSize).ceil(),
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
    _verifyMaxTopAndLeft(gameRef.size, isUpdate: true);
  }

  @override
  Size getMapSize() {
    double height = 0;
    double width = 0;

    this.tiles.forEach((tile) {
      if (tile.right > width) width = tile.right;
      if (tile.bottom > height) height = tile.bottom;
    });

    return Size(width, height);
  }

  Vector2 getStartPosition() {
    try {
      double x = this.tiles.first.left;
      double y = this.tiles.first.top;

      this.tiles.forEach((tile) {
        if (tile.left < x) x = tile.left;
        if (tile.top < y) y = tile.top;
      });

      return Vector2(x, y);
    } catch (e) {
      return Vector2.zero();
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
    List<ObjectCollision> aux = [];
    final list = tiles.where((element) {
      return element.collisions?.isNotEmpty == true;
    });

    for (var element in list) {
      final o = element.getTile(gameRef);
      aux.add(o as ObjectCollision);
    }
    _tilesCollisions = aux;
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
    _verifyMaxTopAndLeft(gameRef.size);
    _searchTilesToRender();
  }

  void _verifyRemoveTileOfWord() {
    if (_tilesToRemove.isNotEmpty) {
      for (Tile tile in _tilesToRemove) {
        if (tile.shouldRemove) {
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

  Vector2 _getCameraTileUpdate() {
    return Vector2(
      (gameRef.camera.position.x / tileSizeToUpdate).floorToDouble(),
      (gameRef.camera.position.y / tileSizeToUpdate).floorToDouble(),
    );
  }

  bool _checkNeedUpdateTiles() {
    final camera = _getCameraTileUpdate();
    if (lastCamera != camera || lastMinorZoom > gameRef.camera.zoom) {
      lastCamera = camera;
      if (lastMinorZoom > gameRef.camera.zoom) {
        lastMinorZoom = gameRef.camera.zoom;
      }
      return true;
    }
    return false;
  }
}
