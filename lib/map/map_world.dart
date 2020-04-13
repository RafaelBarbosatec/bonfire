import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/map/tile.dart';

class MapWorld extends MapGame {
  double lastCameraX = -1;
  double lastCameraY = -1;
  Size lastSize;
  Iterable<Tile> tilesToRender = List();
  Iterable<Tile> tilesCollisionsRendered = List();

  MapWorld(Iterable<Tile> tiles) : super(tiles);

  @override
  void render(Canvas canvas) {
    tilesToRender.forEach((tile) => tile.render(canvas));
  }

  @override
  void update(double t) {
    if (lastCameraX != gameRef.gameCamera.position.x ||
        gameRef.gameCamera.position.y != lastCameraY) {
      lastCameraX = gameRef.gameCamera.position.x;
      lastCameraY = gameRef.gameCamera.position.y;

      tiles.forEach((tile) {
        tile.gameRef = gameRef;
        tile.update(t);
      });
      tilesToRender = tiles.where((i) => i.isVisibleInMap());
      tilesCollisionsRendered = tilesToRender.where((i) => i.collision);
    }
  }

  @override
  List<Tile> getRendered() {
    return tilesToRender.toList();
  }

  @override
  List<Tile> getCollisionsRendered() {
    return tilesCollisionsRendered.toList();
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
      if (tile.positionInWorld.bottom > max)
        return tile.positionInWorld.bottom;
      else
        return max;
    });

    maxTop -= size.height;

    maxLeft = tiles.fold(0, (max, tile) {
      if (tile.positionInWorld.right > max)
        return tile.positionInWorld.right;
      else
        return max;
    });
    maxLeft -= size.width;

    gameRef.gameCamera.maxLeft = maxLeft;
    gameRef.gameCamera.maxTop = maxTop;

    lastCameraX = -1;
    lastCameraY = -1;

    if (gameRef.player != null && !gameRef.player.usePositionInWorld) {
      gameRef.player.usePositionInWorldToRender();
    }
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
