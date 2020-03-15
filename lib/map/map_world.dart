import 'dart:ui';

import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/map/tile.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/joystick_controller.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

class MapWorld extends MapGame with HasGameRef<RPGGame> {
  double maxTop = 0;
  double maxLeft = 0;
  double lastCameraX = -1;
  double lastCameraY = -1;
  Iterable<Tile> tilesToRender = List();
  Iterable<Tile> tilesCollisionsRendered = List();

  MapWorld(Iterable<Tile> map) : super(map);

  void verifyMaxTopAndLeft() {
    if (maxLeft == 0 || maxTop == 0) {
      maxTop = map.fold(0, (max, tile) {
        if (tile.initPosition.y > max)
          return tile.initPosition.y;
        else
          return max;
      });
      maxTop = (maxTop * map.first.size) - gameRef.size.height;

      maxLeft = map.fold(0, (max, tile) {
        if (tile.initPosition.x > max)
          return tile.initPosition.x;
        else
          return max;
      });
      maxLeft = (maxLeft * map.first.size) - gameRef.size.width;
    }
  }

  @override
  bool isMaxBottom() {
    return (gameRef.mapCamera.y * -1) >= maxTop;
  }

  @override
  bool isMaxLeft() {
    return gameRef.mapCamera.x == 0;
  }

  @override
  bool isMaxRight() {
    return (gameRef.mapCamera.x * -1) >= maxLeft;
  }

  @override
  bool isMaxTop() {
    return gameRef.mapCamera.y == 0;
  }

  @override
  void moveCamera(double displacement, JoystickMoveDirectional directional) {
    switch (directional) {
      case JoystickMoveDirectional.MOVE_TOP:
        if (gameRef.mapCamera.y > 0) {
          gameRef.mapCamera.y = 0;
        }
        if (gameRef.mapCamera.y < 0) {
          gameRef.mapCamera.y = gameRef.mapCamera.y + displacement;
        }
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        if (!isMaxRight()) {
          gameRef.mapCamera.x = gameRef.mapCamera.x - displacement;
        }
        break;
      case JoystickMoveDirectional.MOVE_BOTTOM:
        if (!isMaxBottom()) {
          gameRef.mapCamera.y = gameRef.mapCamera.y - displacement;
        }
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        if (gameRef.mapCamera.x > 0) {
          gameRef.mapCamera.x = 0;
        }
        if (!isMaxLeft()) {
          gameRef.mapCamera.x = gameRef.mapCamera.x + displacement;
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
    if (lastCameraX != gameRef.mapCamera.x ||
        gameRef.mapCamera.y != lastCameraY) {
      lastCameraX = gameRef.mapCamera.x;
      lastCameraY = gameRef.mapCamera.y;
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
