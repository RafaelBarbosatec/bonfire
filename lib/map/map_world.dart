import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/map/tile/tile_model.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MapWorld extends MapGame {
  static const int SIZE_LOT_TILES_TO_PROCESS = 1000;
  int lastCameraX = -1;
  int lastCameraY = -1;
  double lastZoom = -1;
  Vector2? lastSizeScreen;
  Iterable<Tile> _tilesToRender = [];
  Iterable<Tile> _tilesToUpdate = [];
  Iterable<ObjectCollision> _tilesCollisions = [];
  Iterable<ObjectCollision> _tilesVisibleCollisions = [];
  List<Iterable<TileModel>> _tilesLot = [];
  List<Tile> _auxTiles = [];
  bool processingTiles = false;

  List<Offset> _linePath = [];
  Paint _paintPath = Paint()
    ..color = Colors.lightBlueAccent.withOpacity(0.8)
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  int currentIndexProcess = -1;

  MapWorld(List<TileModel> tiles, {double tileSizeToUpdate = 0})
      : super(
          tiles,
          tileSizeToUpdate: tileSizeToUpdate,
        );

  @override
  void render(Canvas canvas) {
    for (final tile in _tilesToRender) {
      tile.render(canvas);
    }
    _drawPathLine(canvas);
  }

  @override
  void update(double t) {
    final cameraX = (gameRef.camera.position.dx / tileSizeToUpdate).floor();
    final cameraY = (gameRef.camera.position.dy / tileSizeToUpdate).floor();
    if (lastCameraX != cameraX ||
        lastCameraY != cameraY ||
        lastZoom > gameRef.camera.config.zoom) {
      lastCameraX = cameraX;
      lastCameraY = cameraY;
      if (lastZoom > gameRef.camera.config.zoom) {
        lastZoom = gameRef.camera.config.zoom;
      }
      if (currentIndexProcess == -1) {
        currentIndexProcess = 0;
      }
    }

    for (final tile in _tilesToUpdate) {
      tile.update(t);
    }

    if (currentIndexProcess != -1 && !processingTiles) {
      processingTiles = true;
      scheduleMicrotask(_updateTilesToRender);
    }
  }

  Future<void> _updateTilesToRender({bool processAllList = false}) async {
    Iterable<TileModel> visibleTiles =
        (processAllList ? tiles : _tilesLot[currentIndexProcess])
            .where((tile) => gameRef.camera.contains(tile.center));

    if (visibleTiles.isNotEmpty) {
      _auxTiles.addAll(await _buildAsyncTiles(visibleTiles));
    }

    currentIndexProcess++;
    if (currentIndexProcess >= _tilesLot.length || processAllList) {
      _tilesToRender = _auxTiles.toList(growable: false);
      _tilesToUpdate = _tilesToRender.where((element) {
        return element is ObjectCollision || element.containAnimation;
      });
      _tilesVisibleCollisions = _tilesToUpdate.where((element) {
        return element is ObjectCollision;
      }).cast();
      _auxTiles.clear();
      currentIndexProcess = -1;
    }
    processingTiles = false;
  }

  @override
  Iterable<Tile> getRendered() {
    return _tilesToRender;
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
    verifyMaxTopAndLeft(size);
    super.onGameResize(size);
  }

  void verifyMaxTopAndLeft(Vector2 size, {bool isUpdate = false}) {
    if (lastSizeScreen == size) return;
    lastSizeScreen = size.clone();

    if (isUpdate) {
      lastCameraX = -1;
      lastCameraY = -1;
      lastZoom = -1;
    }

    mapSize = getMapSize();
    mapStartPosition = getStartPosition();
    if (tiles.isNotEmpty && tileSizeToUpdate == 0) {
      tileSizeToUpdate = max(size.x, size.y) / 3;
      tileSizeToUpdate = tileSizeToUpdate.ceilToDouble();
    }
    gameRef.camera.updateSpacingVisibleMap(tileSizeToUpdate * 1.5);

    _getTileCollisions();

    _createTilesLot();
  }

  void _createTilesLot() {
    final countTiles = tiles.length;
    final countFramesToProcess =
        (countTiles / SIZE_LOT_TILES_TO_PROCESS).ceil();
    _tilesLot.clear();
    List.generate(countFramesToProcess, (index) {
      int startRange = SIZE_LOT_TILES_TO_PROCESS * index;
      int endRange = SIZE_LOT_TILES_TO_PROCESS * (index + 1);
      if (index == countFramesToProcess - 1) {
        endRange = countTiles;
      }
      _tilesLot.add(tiles.getRange(startRange, endRange));
    });
  }

  @override
  Future<void> updateTiles(List<TileModel> map) async {
    lastSizeScreen = null;
    this.tiles = map;
    verifyMaxTopAndLeft(gameRef.size, isUpdate: true);
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

  void _getTileCollisions() async {
    List<ObjectCollision> aux = [];
    final list = tiles.where((element) {
      return element.collisions?.isNotEmpty == true;
    });

    for (var element in list) {
      final o = element.getTile(gameRef);
      await o.onLoad();
      aux.add(o as ObjectCollision);
    }
    _tilesCollisions = aux;
  }

  Future<List<Tile>> _buildAsyncTiles(Iterable<TileModel> visibleTiles) async {
    List<Tile> aux = [];
    for (var element in visibleTiles) {
      final tile = element.getTile(gameRef);
      await tile.onLoad();
      aux.add(tile);
    }
    return aux;
  }

  @override
  Future<void>? onLoad() async {
    return _updateTilesToRender(processAllList: true);
  }
}
