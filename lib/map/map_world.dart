import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/map/tile.dart';

class MapWorld extends MapGame {
  double lastCameraX = -1;
  double lastCameraY = -1;
  Size _sizeScreen;
  Iterable<Tile> tilesToRender = List();
  Iterable<Tile> tilesCollisionsRendered = List();

  MapWorld(Iterable<Tile> map) : super(map);

  @override
  void render(Canvas canvas) {
    tilesToRender
        .forEach((tile) => tile.render(canvas, gameRef.gameCamera.position));
  }

  @override
  void update(double t) {
    if (lastCameraX != gameRef.gameCamera.position.x ||
        gameRef.gameCamera.position.y != lastCameraY) {
      lastCameraX = gameRef.gameCamera.position.x;
      lastCameraY = gameRef.gameCamera.position.y;
      map.forEach((tile) => tile.update(gameRef));
      tilesToRender = map.where((i) => i.isVisible());
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
    verifyMaxTopAndLeft();
    super.resize(size);
  }

  void verifyMaxTopAndLeft() {
    if (gameRef.size != null && _sizeScreen != gameRef.size) {
      double maxTop = 0;
      double maxLeft = 0;
      _sizeScreen = gameRef.size;
      maxTop = map.fold(0, (max, tile) {
        if (tile.position.bottom > max)
          return tile.position.bottom;
        else
          return max;
      });

      maxTop -= _sizeScreen.height;

      maxLeft = map.fold(0, (max, tile) {
        if (tile.position.right > max)
          return tile.position.right;
        else
          return max;
      });
      maxLeft -= _sizeScreen.width;

      gameRef.gameCamera.maxLeft = maxLeft;
      gameRef.gameCamera.maxTop = maxTop;

      lastCameraX = -1;
      lastCameraY = -1;

      if (gameRef.player != null && !gameRef.player.usePositionInWorld) {
        gameRef.player.usePositionInWorldToRender();
      }
      gameRef.gameCamera.moveToPlayer();
    }
  }

  @override
  void updateTiles(Iterable<Tile> map) {
    lastCameraX = -1;
    lastCameraY = -1;
    _sizeScreen = null;
    this.map = map;
  }
}
