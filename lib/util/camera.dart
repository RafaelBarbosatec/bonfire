import 'package:bonfire/bonfire.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flutter/widgets.dart';

class Camera with HasGameRef<RPGGame> {
  double maxTop = 0;
  double maxLeft = 0;
  Position position = Position.empty();

  bool isMaxBottom() {
    return (position.y * -1) >= maxTop;
  }

  bool isMaxLeft() {
    return position.x == 0;
  }

  bool isMaxRight() {
    return (position.x * -1) >= maxLeft;
  }

  bool isMaxTop() {
    return position.y == 0;
  }

  void moveTop(double displacement) {
    if (position.y < 0) {
      position.y = position.y + displacement;
    }
    if (position.y > 0) {
      position.y = 0;
    }
  }

  void moveRight(double displacement) {
    if (!isMaxRight()) {
      gameRef.gameCamera.position.x =
          gameRef.gameCamera.position.x - displacement;
    }
  }

  void moveBottom(double displacement) {
    if (!isMaxBottom()) {
      gameRef.gameCamera.position.y =
          gameRef.gameCamera.position.y - displacement;
    }
  }

  void moveLeft(double displacement) {
    if (!isMaxLeft()) {
      position.x = position.x + displacement;
    }
    if (position.x > 0) {
      position.x = 0;
    }
  }

  void moveCamera(double displacement, JoystickMoveDirectional directional) {
    switch (directional) {
      case JoystickMoveDirectional.MOVE_UP:
        gameRef.gameCamera.moveTop(displacement);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        gameRef.gameCamera.moveRight(displacement);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        gameRef.gameCamera.moveBottom(displacement);
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        gameRef.gameCamera.moveLeft(displacement);
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        break;
      case JoystickMoveDirectional.IDLE:
        break;
    }
  }

  void moveToPositionAnimated(
    Position position, {
    VoidCallback finish,
    Duration duration,
    Curve curve = Curves.decelerate,
  }) {
    gameRef.player.usePositionInWorldToRender();
    double distanceLeft = gameRef.size.width / 2;
    double distanceTop = gameRef.size.height / 2;

    double positionLeftCamera = position.x - distanceLeft;
    double positionTopCamera = position.y - distanceTop;

    if (positionLeftCamera > maxLeft) positionLeftCamera = maxLeft;

    positionLeftCamera *= -1;
    if (positionLeftCamera > 0) positionLeftCamera = 0;

    if (positionTopCamera * -1 > maxTop) positionTopCamera = maxTop;
    positionTopCamera *= -1;
    if (positionTopCamera > 0) positionTopCamera = 0;

    double diffX = this.position.x - positionLeftCamera;
    double diffY = this.position.y - positionTopCamera;
    double originX = this.position.x;
    double originY = this.position.y;

    gameRef.getValueGenerator(duration ?? Duration(seconds: 1))
      ..addListenerValue((value) {
        this.position.x = originX - (diffX * value);
        this.position.y = originY - (diffY * value);
      })
      ..addListenerFinish(() {
        if (finish != null) finish();
      })
      ..addCurve(curve)
      ..start();
  }

  void moveToPosition(Position position) {
    gameRef.player.usePositionInWorldToRender();
    double distanceLeft = gameRef.size.width / 2;
    double distanceTop = gameRef.size.height / 2;

    double positionLeftCamera = position.x - distanceLeft;
    double positionTopCamera = position.y - distanceTop;

    if (positionLeftCamera > maxLeft) positionLeftCamera = maxLeft;

    positionLeftCamera *= -1;
    if (positionLeftCamera > 0) positionLeftCamera = 0;

    if (positionTopCamera * -1 > maxTop) positionTopCamera = maxTop;
    positionTopCamera *= -1;
    if (positionTopCamera > 0) positionTopCamera = 0;

    this.position.x = positionLeftCamera;
    this.position.y = positionTopCamera;
  }

  void moveToPlayerAnimated({Duration duration, VoidCallback finish}) {
    if (gameRef.player == null) return;
    Rect _positionPlayer = gameRef.player.positionInWorld;
    moveToPositionAnimated(
      Position(_positionPlayer.left, _positionPlayer.top),
      finish: () {
        gameRef.player.usePositionToRender();
        if (finish != null) finish();
      },
      duration: duration,
    );
  }

  void moveToPlayer() {
    if (gameRef.player == null) return;
    Rect _positionPlayer = gameRef.player.positionInWorld;
    moveToPosition(Position(_positionPlayer.left, _positionPlayer.top));
    gameRef.player.usePositionToRender();
  }
}
