import 'package:bonfire/bonfire.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/game_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flutter/widgets.dart';

class Camera with HasGameRef<RPGGame> {
  double maxTop = 0;
  double maxLeft = 0;
  Position position = Position.empty();

  Rect get cameraRect => Rect.fromLTWH(
        position.x - 10,
        position.y - 10,
        gameRef.size.width + 10,
        gameRef.size.height + 10,
      );

  void moveTop(double displacement) {
    position.y = position.y - displacement;
  }

  void moveRight(double displacement) {
    position.x = position.x + displacement;
  }

  void moveBottom(double displacement) {
    position.y = position.y + displacement;
  }

  void moveLeft(double displacement) {
    position.x = position.x - displacement;
  }

  void moveCamera(double displacement, JoystickMoveDirectional directional) {
    switch (directional) {
      case JoystickMoveDirectional.MOVE_UP:
        moveTop(displacement);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        moveRight(displacement);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        moveBottom(displacement);
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        moveLeft(displacement);
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
    if (gameRef?.size == null) return;
    final screenCenter =
        Position(gameRef.size.width / 2, gameRef.size.height / 2);
    if (gameRef?.player != null) gameRef.player.focusCamera = false;

    double diffX = this.position.x - (position.x - screenCenter.x);
    double diffY = this.position.y - (position.y - screenCenter.y);
    double originX = this.position.x;
    double originY = this.position.y;

    gameRef.getValueGenerator(duration ?? Duration(seconds: 1))
      ..addListenerValue((value) {
        this.position.x = originX - (diffX * value);
        this.position.y = originY - (diffY * value);
      })
      ..addListenerFinish(finish)
      ..addCurve(curve)
      ..start();
  }

  void moveToPosition(Position position) {
    if (gameRef?.size == null) return;
    if (gameRef?.player != null) gameRef.player.focusCamera = false;
    final screenCenter =
        Position(gameRef.size.width / 2, gameRef.size.height / 2);
    this.position = position - screenCenter;
  }

  void moveToPlayerAnimated({Duration duration, VoidCallback finish}) {
    if (gameRef.player == null) return;
    final _positionPlayer = gameRef.player.position;
    moveToPositionAnimated(
      Position(_positionPlayer.center.dx, _positionPlayer.center.dy),
      finish: () {
        gameRef.player.focusCamera = true;
        if (finish != null) finish();
      },
      duration: duration,
    );
  }

  void moveToPlayer({double horizontal = 50, double vertical = 50}) {
    if (gameRef?.player == null || gameRef?.size == null) return;
    final screenCenter =
        Offset(gameRef.size.width / 2, gameRef.size.height / 2);
    final positionPlayer =
        worldPositionToScreen(gameRef.player.position.center);
    final horizontalDistance = screenCenter.dx - positionPlayer.dx;
    final verticalDistance = screenCenter.dy - positionPlayer.dy;
    if (horizontalDistance.abs() > horizontal) {
      this.gameRef.gameCamera.position.x += horizontalDistance > 0
          ? horizontal - horizontalDistance
          : -horizontalDistance - horizontal;
    }
    if (verticalDistance.abs() > vertical) {
      this.gameRef.gameCamera.position.y += verticalDistance > 0
          ? vertical - verticalDistance
          : -verticalDistance - vertical;
    }
    gameRef.player.focusCamera = true;
  }

  bool isComponentOnCamera(GameComponent c) {
    if (gameRef?.size == null || c.position == null) return false;

    return cameraRect.overlaps(c.position);
  }

  Offset worldPositionToScreen(Offset position) {
    return position.translate(
        -gameRef.gameCamera.position.x, -gameRef.gameCamera.position.y);
  }

  Offset cameraPositionToWorld(Offset position) {
    return position.translate(
        gameRef.gameCamera.position.x, gameRef.gameCamera.position.y);
  }
}
