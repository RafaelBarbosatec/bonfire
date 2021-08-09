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
  int lastCameraX = -1;
  int lastCameraY = -1;
  double lastZoom = -1;
  Vector2? lastSizeScreen;
  List<Tile> _tilesToRender = [];
  Iterable<ObjectCollision> _tilesCollisions = [];
  List<Tile> _auxTiles = [];
  Rect tilesRenderRect = Rect.zero;

  List<Offset> _linePath = [];
  Paint _paintPath = Paint()
    ..color = Colors.lightBlueAccent.withOpacity(0.8)
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  List<Tile> _addLaterTiles = [];

  MapWorld(Iterable<TileModel> tiles, {double tileSizeToUpdate = 0})
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
      if (_addLaterTiles.isEmpty) {
        scheduleMicrotask(_updateTilesToRender);
      }
    }

    if (_addLaterTiles.isNotEmpty) {
      final newTiles = _addLaterTiles.toList(growable: false);
      _tilesToRender.addAll(newTiles);
      _tilesToRender.retainWhere((element) => element.isVisibleInCamera());
      _calculateRectAndUpdate(t);
      _addLaterTiles.clear();
    } else {
      for (final tile in _tilesToRender) {
        tile.update(t);
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

  void verifyMaxTopAndLeft(Vector2 size) {
    if (lastSizeScreen == size) return;
    lastSizeScreen = size.clone();

    lastCameraX = -1;
    lastCameraY = -1;
    lastZoom = -1;
    mapSize = getMapSize();
    mapStartPosition = getStartPosition();
    if (tiles.isNotEmpty && tileSizeToUpdate == 0) {
      tileSizeToUpdate = max(size.x, size.y) / 3;
      tileSizeToUpdate = tileSizeToUpdate.ceilToDouble();
    }
    gameRef.camera.updateSpacingVisibleMap(tileSizeToUpdate * 1.5);
    _getTileCollisions();
  }

  @override
  Future<void> updateTiles(Iterable<TileModel> map) async {
    lastCameraX = -1;
    lastCameraY = -1;
    lastZoom = -1;
    lastSizeScreen = null;
    this.tiles = map;
    verifyMaxTopAndLeft(gameRef.size);
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

  Future<void> _updateTilesToRender() async {
    if (_addLaterTiles.isEmpty) {
      final visibleTiles = tiles.where((tile) {
        return gameRef.camera.contains(tile.center) &&
            !tilesRenderRect.contains(tile.center);
      });
      await _buildAsyncTiles(visibleTiles);
      _addLaterTiles = _auxTiles;
    }
  }

  void _getTileCollisions() async {
    List<ObjectCollision> aux = [];
    final list = tiles.where((element) {
      return element.collisions?.isNotEmpty == true;
    });

    for (final element in list) {
      final o = element.getTile(gameRef);
      await o.onLoad();
      aux.add(o as ObjectCollision);
    }
    _tilesCollisions = aux;
  }

  Future<void> _buildAsyncTiles(Iterable<TileModel> visibleTiles) async {
    _auxTiles.clear();
    for (final element in visibleTiles) {
      final tile = element.getTile(gameRef);
      await tile.onLoad();
      _auxTiles.add(tile);
    }
  }

  @override
  Future<void>? onLoad() async {
    return _updateTilesToRender();
  }

  void _calculateRectAndUpdate(double dt) {
    double left = _tilesToRender.first.position.left;
    double top = _tilesToRender.first.position.top;
    double right = _tilesToRender.first.position.right;
    double bottom = _tilesToRender.first.position.bottom;
    for (final tile in _tilesToRender) {
      tile.update(dt);
      if (tile.position.left < left) {
        left = tile.position.left;
      }
      if (tile.position.top < top) {
        top = tile.position.top;
      }

      if (tile.position.right > right) {
        right = tile.position.right;
      }

      if (tile.position.bottom > bottom) {
        bottom = tile.position.bottom;
      }
    }

    tilesRenderRect = Rect.fromLTRB(left, top, right, bottom);
  }
}
