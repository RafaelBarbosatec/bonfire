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
  Iterable<ObjectCollision> _tilesCollisions = [];
  List<Tile> _auxTiles = [];

  List<Offset> _linePath = [];
  Paint _paintPath = Paint()
    ..color = Colors.lightBlueAccent.withOpacity(0.8)
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  int currentIndexProcess = -1;
  int countTiles = 0;
  int countFramesToProcess = 0;

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

    for (final tile in getTilesToUpdate()) {
      tile.update(t);
    }

    if (currentIndexProcess != -1) {
      scheduleMicrotask(_updateTilesToRender);
    }
  }

  Iterable<Tile> getTilesToUpdate() {
    return _tilesToRender.where((element) {
      return element is ObjectCollision || element.containAnimation;
    });
  }

  Future<void> _updateTilesToRender({bool processAllList = false}) async {
    if (currentIndexProcess != -1 || processAllList) {
      int startRange = SIZE_LOT_TILES_TO_PROCESS * currentIndexProcess;
      int endRange = SIZE_LOT_TILES_TO_PROCESS * (currentIndexProcess + 1);
      if (currentIndexProcess == countFramesToProcess) {
        endRange = countTiles;
      }

      Iterable<TileModel> visibleTiles =
          (processAllList ? tiles : tiles.getRange(startRange, endRange))
              .where((tile) => gameRef.camera.contains(tile.center));

      if (visibleTiles.isNotEmpty) {
        await _buildAsyncTiles(visibleTiles);
      }

      currentIndexProcess++;
      if (currentIndexProcess > countFramesToProcess || processAllList) {
        _tilesToRender = _auxTiles.toList(growable: false);
        _auxTiles.clear();
        currentIndexProcess = -1;
      }
    }
  }

  @override
  Iterable<Tile> getRendered() {
    return _tilesToRender;
  }

  @override
  Iterable<ObjectCollision> getCollisionsRendered() {
    return _tilesToRender.where((element) => element is ObjectCollision).cast();
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

    countTiles = tiles.length;
    countFramesToProcess = (countTiles / SIZE_LOT_TILES_TO_PROCESS).floor();
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

  Future<void> _buildAsyncTiles(Iterable<TileModel> visibleTiles) async {
    for (var element in visibleTiles) {
      final tile = element.getTile(gameRef);
      await tile.onLoad();
      _auxTiles.add(tile);
    }
  }

  @override
  Future<void>? onLoad() async {
    return _updateTilesToRender(processAllList: true);
  }
}
