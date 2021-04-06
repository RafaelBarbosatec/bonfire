import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

class MapWorld extends MapGame {
  double lastCameraX = -1;
  double lastCameraY = -1;
  double lastZoom = -1;
  Vector2? lastSizeScreen;
  Iterable<Tile> _tilesToRender = [];
  Iterable<Tile> _tilesCollisionsRendered = [];
  Iterable<Tile> _tilesCollisions = [];

  MapWorld(Iterable<Tile> tiles) : super(tiles) {
    _tilesCollisions = tiles.where((element) =>
        (element is ObjectCollision) &&
        (element as ObjectCollision).containCollision());
  }

  @override
  void render(Canvas canvas) {
    for (final tile in _tilesToRender) {
      tile.render(canvas);
    }
  }

  @override
  void update(double t) {
    if (lastCameraX != gameRef.gameCamera.position.dx ||
        lastCameraY != gameRef.gameCamera.position.dy ||
        lastZoom != gameRef.gameCamera.zoom) {
      lastCameraX = gameRef.gameCamera.position.dx;
      lastCameraY = gameRef.gameCamera.position.dy;
      lastZoom = gameRef.gameCamera.zoom;

      List<Tile> tilesRender = [];
      List<Tile> tilesCollision = [];
      for (final tile in tiles) {
        tile.gameRef = gameRef;
        if (tile.isVisibleInCamera()) {
          tilesRender.add(tile);
          if ((tile is ObjectCollision) &&
              (tile as ObjectCollision).containCollision())
            tilesCollision.add(tile);
        }
      }
      _tilesToRender = tilesRender;
      _tilesCollisionsRendered = tilesCollision;
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
  Iterable<Tile> getCollisionsRendered() {
    return _tilesCollisionsRendered;
  }

  @override
  Iterable<Tile> getCollisions() {
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
  }

  @override
  Future<void> updateTiles(Iterable<Tile> map) async {
    lastCameraX = -1;
    lastCameraY = -1;
    lastZoom = -1;
    lastSizeScreen = null;
    this.tiles = map;
    await onLoad();
    verifyMaxTopAndLeft(gameRef.size);
  }

  @override
  Size getMapSize() {
    double height = 0;
    double width = 0;

    this.tiles.forEach((tile) {
      if (tile.position.rect.right > width) width = tile.position.rect.right;
      if (tile.position.rect.bottom > height) height = tile.position.bottom;
    });

    return Size(width, height);
  }

  Vector2 getStartPosition() {
    try {
      double x = this.tiles.first.position.rect.left;
      double y = this.tiles.first.position.rect.top;

      this.tiles.forEach((tile) {
        if (tile.position.rect.left < x) x = tile.position.rect.left;
        if (tile.position.rect.top < y) y = tile.position.rect.top;
      });

      return Vector2(x, y);
    } catch (e) {
      return Vector2.zero();
    }
  }
}
