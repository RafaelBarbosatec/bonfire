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
    verifyMaxTopAndLeft();
    if (lastCameraX != gameRef.gameCamera.position.x ||
        gameRef.gameCamera.position.y != lastCameraY) {
      lastCameraX = gameRef.gameCamera.position.x;
      lastCameraY = gameRef.gameCamera.position.y;
      map.forEach((tile) => tile.update(gameRef));
      tilesToRender = map.where((i) => i.isVisible(gameRef));
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

  void verifyMaxTopAndLeft() {
    if (gameRef.size != null && _sizeScreen != gameRef.size) {
      double maxTop = 0;
      double maxLeft = 0;
      _sizeScreen = gameRef.size;
      maxTop = map.fold(0, (max, tile) {
        if (tile.initPosition.y > max)
          return tile.initPosition.y;
        else
          return max;
      });
      maxTop = (maxTop * map.first.size) - _sizeScreen.height;

      maxLeft = map.fold(0, (max, tile) {
        if (tile.initPosition.x > max)
          return tile.initPosition.x;
        else
          return max;
      });
      maxLeft = (maxLeft * map.first.size) - _sizeScreen.width;

      gameRef.gameCamera.maxLeft = maxLeft;
      gameRef.gameCamera.maxTop = maxTop;
      gameRef.gameCamera.moveToPlayer();
    }
  }
}
