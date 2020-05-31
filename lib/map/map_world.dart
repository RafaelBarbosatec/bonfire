import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/map/tile.dart';
import 'package:flutter/cupertino.dart';

class MapWorld extends MapGame {
  double lastCameraX = -1;
  double lastCameraY = -1;
  Size lastSize;
  Iterable<Tile> _tilesToRender = List();
  Iterable<Tile> _tilesCollisionsRendered = List();
  bool _fistRenderComplete = false;
  final ValueChanged<double> progressLoadMap;

  MapWorld(Iterable<Tile> tiles, {this.progressLoadMap}) : super(tiles);

  @override
  void render(Canvas canvas) {
    _tilesToRender.forEach((tile) => tile.render(canvas));
  }

  @override
  void update(double t) {
    if (lastCameraX != gameRef.gameCamera.position.x ||
        gameRef.gameCamera.position.y != lastCameraY) {
      lastCameraX = gameRef.gameCamera.position.x;
      lastCameraY = gameRef.gameCamera.position.y;

      List<Tile> tilesRender = List();
      List<Tile> tilesCollision = List();
      tiles.forEach((tile) {
        tile.gameRef = gameRef;
        tile.update(t);
        if (tile.isVisibleInMap()) {
          tilesRender.add(tile);
          if (tile.collision) tilesCollision.add(tile);
        }
      });
      _tilesToRender = tilesRender;
      _tilesCollisionsRendered = tilesCollision;
    }
    if (!_fistRenderComplete) {
      int count = _tilesToRender.length;
      int countRendered =
          _tilesToRender.where((tile) => tile.sprite.loaded()).length;
      double percent = countRendered / count;
      if (!percent.isNaN && progressLoadMap != null) {
        progressLoadMap(percent);
      }
      if (percent == 1) {
        _fistRenderComplete = true;
      }
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
  void resize(Size size) {
    verifyMaxTopAndLeft(size);
    super.resize(size);
  }

  void verifyMaxTopAndLeft(Size size) {
    if (lastSize == size) return;
    lastSize = size;
    double maxTop = 0;
    double maxLeft = 0;
    maxTop = tiles.fold(0, (max, tile) {
      if (tile.position.bottom > max)
        return tile.position.bottom;
      else
        return max;
    });

    maxTop -= size.height;

    maxLeft = tiles.fold(0, (max, tile) {
      if (tile.position.right > max)
        return tile.position.right;
      else
        return max;
    });
    maxLeft -= size.width;

    gameRef.gameCamera.maxLeft = maxLeft;
    gameRef.gameCamera.maxTop = maxTop;

    lastCameraX = -1;
    lastCameraY = -1;

    gameRef.gameCamera.moveToPlayer();
  }

  @override
  void updateTiles(Iterable<Tile> map) {
    lastCameraX = -1;
    lastCameraY = -1;
    lastSize = null;
    this.tiles = map;
    verifyMaxTopAndLeft(gameRef.size);
  }
}
