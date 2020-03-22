import 'dart:ui';

import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/map/tile.dart';

class MapWorld extends MapGame {
  double maxTop = 0;
  double maxLeft = 0;
  double lastCameraX = -1;
  double lastCameraY = -1;
  Size _sizeScreen;
  Iterable<Tile> tilesToRender = List();
  Iterable<Tile> tilesCollisionsRendered = List();

  MapWorld(Iterable<Tile> map) : super(map);

  void verifyMaxTopAndLeft() {
    if (gameRef.size != null && _sizeScreen != gameRef.size) {
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

      gameRef.mapCamera.maxLeft = maxLeft;
      gameRef.mapCamera.maxTop = maxTop;
    }
  }

  @override
  bool isMaxBottom() {
    return (gameRef.mapCamera.position.y * -1) >= maxTop;
  }

  @override
  bool isMaxLeft() {
    return gameRef.mapCamera.position.x == 0;
  }

  @override
  bool isMaxRight() {
    return (gameRef.mapCamera.position.x * -1) >= maxLeft;
  }

  @override
  bool isMaxTop() {
    return gameRef.mapCamera.position.y == 0;
  }

  @override
  void moveCamera(double displacement, JoystickMoveDirectional directional) {
    switch (directional) {
      case JoystickMoveDirectional.MOVE_TOP:
        if (gameRef.mapCamera.position.y > 0) {
          gameRef.mapCamera.position.y = 0;
        }
        if (gameRef.mapCamera.position.y < 0) {
          gameRef.mapCamera.position.y =
              gameRef.mapCamera.position.y + displacement;
        }
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        if (!isMaxRight()) {
          gameRef.mapCamera.position.x =
              gameRef.mapCamera.position.x - displacement;
        }
        break;
      case JoystickMoveDirectional.MOVE_BOTTOM:
        if (!isMaxBottom()) {
          gameRef.mapCamera.position.y =
              gameRef.mapCamera.position.y - displacement;
        }
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        if (gameRef.mapCamera.position.x > 0) {
          gameRef.mapCamera.position.x = 0;
        }
        if (!isMaxLeft()) {
          gameRef.mapCamera.position.x =
              gameRef.mapCamera.position.x + displacement;
        }
        break;
      case JoystickMoveDirectional.MOVE_TOP_LEFT:
        break;
      case JoystickMoveDirectional.MOVE_TOP_RIGHT:
        break;
      case JoystickMoveDirectional.MOVE_BOTTOM_RIGHT:
        break;
      case JoystickMoveDirectional.MOVE_BOTTOM_LEFT:
        break;
      case JoystickMoveDirectional.IDLE:
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    tilesToRender.forEach((tile) => tile.render(canvas, gameRef.camera));
  }

  @override
  void update(double t) {
    verifyMaxTopAndLeft();
    if (lastCameraX != gameRef.mapCamera.position.x ||
        gameRef.mapCamera.position.y != lastCameraY) {
      lastCameraX = gameRef.mapCamera.position.x;
      lastCameraY = gameRef.mapCamera.position.y;
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
}
