import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/map/tile/tile_model.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MapWorld extends MapGame {
  int lastCameraX = -1;
  int lastCameraY = -1;
  double lastZoom = -1;
  Vector2? lastSizeScreen;
  Iterable<Tile> _tilesToRender = [];
  List<ObjectCollision> _tilesCollisionsRendered = [];
  Iterable<ObjectCollision> _tilesCollisions = [];
  List<Tile> _auxTiles = [];
  List<ObjectCollision> _auxCollisionTiles = [];

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
      _tilesToRender = _addLaterTiles.toList(growable: false);
      _addLaterTiles.clear();
    }

    for (final tile in _tilesToRender) {
      tile.update(t);
    }
  }

  @override
  Iterable<Tile> getRendered() {
    return _tilesToRender;
  }

  @override
  Iterable<ObjectCollision> getCollisionsRendered() {
    return _tilesCollisionsRendered;
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
      final visibleTiles = tiles.where(
        (tile) => gameRef.camera.contains(tile.center),
      );
      await _buildAsyncTiles(visibleTiles);
      _addLaterTiles = _auxTiles;
      _tilesCollisionsRendered = _auxCollisionTiles.toList(growable: false);
    }
  }

  void _getTileCollisions() async {
    List<ObjectCollision> aux = [];
    final list = tiles.where((element) {
      return element.collisions?.isNotEmpty == true;
    });

    for (final element in list) {
      final o = element.getTile(gameRef);
      ;
      await o.onLoad();
      aux.add(o as ObjectCollision);
    }
    _tilesCollisions = aux;
  }

  Future<void> _buildAsyncTiles(Iterable<TileModel> visibleTiles) async {
    _auxCollisionTiles.clear();
    _auxTiles.clear();
    for (final element in visibleTiles) {
      final tile = element.getTile(gameRef);
      if (tile is ObjectCollision) {
        _auxCollisionTiles.add(tile as ObjectCollision);
      }
      await tile.onLoad();
      _auxTiles.add(tile);
    }
  }

  @override
  Future<void>? onLoad() async {
    lastCameraX = (gameRef.camera.position.dx / tileSizeToUpdate).floor();
    lastCameraY = (gameRef.camera.position.dy / tileSizeToUpdate).floor();
    lastZoom = gameRef.camera.config.zoom;
    return _updateTilesToRender();
  }
}
