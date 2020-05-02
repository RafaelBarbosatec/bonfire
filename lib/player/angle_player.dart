import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flutter/painting.dart';

class AnglePlayer extends Player {
  final FlameAnimation.Animation animIdle;
  final FlameAnimation.Animation animRun;
  double speed;
  double currentRadAngle = 0.0;
  double _dtUpdate = 0.0;
  bool _move = false;

  AnglePlayer({
    Position initPosition,
    this.animIdle,
    this.animRun,
    this.speed = 150,
    double width = 32,
    double height = 32,
    double life = 100,
    Collision collision,
    Size sizeCentralMovementWindow,
  }) : super(
            initPosition: initPosition,
            width: width,
            height: height,
            life: life,
            collision: collision,
            sizeCentralMovementWindow: sizeCentralMovementWindow) {
    this.animation = animIdle;
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    if (event.directional != JoystickMoveDirectional.IDLE && !isDead) {
      currentRadAngle = event.radAngle;
      _move = true;
      this.animation = animRun;
    } else {
      _move = false;
      this.animation = animIdle;
    }
    super.joystickChangeDirectional(event);
  }

  @override
  void render(Canvas canvas) {
    if (_move && !isDead) {
      _movePlayer();
    }
    canvas.save();
    canvas.translate(position.center.dx, position.center.dy);
    canvas.rotate(currentRadAngle == 0.0 ? 0.0 : currentRadAngle + (pi / 2));
    canvas.translate(-position.center.dx, -position.center.dy);
    super.render(canvas);
    canvas.restore();
  }

  @override
  void update(double dt) {
    _dtUpdate = dt;
    super.update(dt);
  }

  void _movePlayer() {
    double nextX = (speed * _dtUpdate) * cos(currentRadAngle);
    double nextY = (speed * _dtUpdate) * sin(currentRadAngle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(position.center.dx + nextPoint.dx,
            position.center.dy + nextPoint.dy) -
        position.center;

    bool enableAxisX = false;
    bool enableAxisY = false;

    if (diffBase.dx > 0) {
      if (position.right <= rectCentralMovementWindow.right ||
          gameRef.gameCamera.isMaxRight()) {
        enableAxisX = true;
      }
    } else if (diffBase.dx < 0) {
      if (position.left >= rectCentralMovementWindow.left ||
          gameRef.gameCamera.isMaxLeft()) {
        enableAxisX = true;
      }
    }

    if (diffBase.dy > 0) {
      if (position.bottom <= rectCentralMovementWindow.bottom ||
          gameRef.gameCamera.isMaxBottom()) {
        enableAxisY = true;
      }
    } else if (diffBase.dy < 0) {
      if (position.top >= rectCentralMovementWindow.top ||
          gameRef.gameCamera.isMaxTop()) {
        enableAxisY = true;
      }
    }

    Offset newDiffBase = diffBase;
    if (!enableAxisX) {
      newDiffBase = Offset(0, diffBase.dy);
    }

    if (!enableAxisY) {
      newDiffBase = Offset(diffBase.dx, 0);
    }

    Rect newPosition = position.shift(newDiffBase);
    if (isCollision(newPosition, gameRef)) return;

    position = newPosition;

    if (!enableAxisX) {
      print(diffBase.dx);
      gameRef.gameCamera.moveCamera(
          diffBase.dx < 0 ? (diffBase.dx * -1) : diffBase.dx,
          diffBase.dx < 0
              ? JoystickMoveDirectional.MOVE_LEFT
              : JoystickMoveDirectional.MOVE_RIGHT);
    }

    if (!enableAxisY) {
      gameRef.gameCamera.moveCamera(
          diffBase.dy < 0 ? (diffBase.dy * 1) : diffBase.dy,
          diffBase.dy < 0
              ? JoystickMoveDirectional.MOVE_UP
              : JoystickMoveDirectional.MOVE_DOWN);
    }
  }
}
