import 'dart:math';

import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/objects/animated_object.dart';
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Player extends AnimatedObject
    with ObjectCollision
    implements JoystickListener {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;

  /// Width of the Player.
  final double width;

  /// Height of the Player.
  final double height;

  /// World position that this Player must position yourself.
  final Position initPosition;

  double life;
  double maxLife;

  bool _isDead = false;

  bool _usePositionInWorld = true;
  bool _nextFrameUsePosition = false;

  final Size sizeCentralMovementWindow;
  Rect rectCentralMovementWindow;

  double dtUpdate = 0;

  Player({
    @required this.initPosition,
    this.width = 32,
    this.height = 32,
    this.life = 100,
    Collision collision,
    this.sizeCentralMovementWindow,
  }) {
    position = positionInWorld = Rect.fromLTWH(
      initPosition.x,
      initPosition.y,
      width,
      height,
    );

    this.collision = collision ?? Collision(width: width, height: height / 2);
    maxLife = life;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (gameRef != null && gameRef.showCollisionArea && this.position != null) {
      drawCollision(canvas, position, gameRef.collisionAreaColor);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_nextFrameUsePosition) {
      _nextFrameUsePosition = false;
      _usePositionInWorld = false;
    }
    dtUpdate = dt;
  }

  void moveTop(double speed) {
    if (position.top <= 0) return;

    double innerSpeed = speed * dtUpdate;

    Rect displacement = position.translate(0, (innerSpeed * -1));

    if (isCollision(displacement, gameRef)) return;

    if (position.top >= rectCentralMovementWindow.top ||
        gameRef.gameCamera.isMaxTop()) {
      position = displacement;
    } else {
      gameRef.gameCamera
          .moveCamera(innerSpeed, JoystickMoveDirectional.MOVE_UP);
    }
  }

  void moveRight(double speed) {
    if (position.right >= gameRef.size.width) return;

    double innerSpeed = speed * dtUpdate;

    Rect displacement = position.translate(innerSpeed, 0);

    if (isCollision(displacement, gameRef)) return;

    if (position.right <= rectCentralMovementWindow.right ||
        gameRef.gameCamera.isMaxRight()) {
      position = displacement;
    } else {
      gameRef.gameCamera
          .moveCamera(innerSpeed, JoystickMoveDirectional.MOVE_RIGHT);
    }
  }

  void moveBottom(double speed) {
    if (position.bottom >= gameRef.size.height) return;

    double innerSpeed = speed * dtUpdate;

    Rect displacement = position.translate(0, innerSpeed);

    if (isCollision(displacement, gameRef)) return;

    if (position.bottom <= rectCentralMovementWindow.bottom ||
        gameRef.gameCamera.isMaxBottom()) {
      position = displacement;
    } else {
      gameRef.gameCamera
          .moveCamera(innerSpeed, JoystickMoveDirectional.MOVE_DOWN);
    }
  }

  void moveLeft(double speed) {
    if (position.left <= 0) return;

    double innerSpeed = speed * dtUpdate;

    Rect displacement = position.translate(innerSpeed * -1, 0);

    if (isCollision(displacement, gameRef)) return;

    if (position.left >= rectCentralMovementWindow.left ||
        gameRef.gameCamera.isMaxLeft()) {
      position = displacement;
    } else {
      gameRef.gameCamera
          .moveCamera(innerSpeed, JoystickMoveDirectional.MOVE_LEFT);
    }
  }

  void moveFromAngle(double speed, double angle) {
    double nextX = (speed * dtUpdate) * cos(angle);
    double nextY = (speed * dtUpdate) * sin(angle);
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

  void receiveDamage(double damage, int from) {
    if (life > 0) {
      life -= damage;
      if (life <= 0) {
        die();
      }
    }
  }

  void die() {
    _isDead = true;
  }

  @override
  void resize(Size size) {
    if (sizeCentralMovementWindow != null) {
      rectCentralMovementWindow = Rect.fromLTWH(
        (size.width / 2) - (sizeCentralMovementWindow.width / 2),
        (size.height / 2) - (sizeCentralMovementWindow.height / 2),
        sizeCentralMovementWindow.width,
        sizeCentralMovementWindow.height,
      );
    } else {
      double sizeWidth = width * 3;
      double sizeHeight = height * 3;
      rectCentralMovementWindow = Rect.fromLTWH(
        (size.width / 2) - (sizeWidth / 2),
        (size.height / 2) - (sizeHeight / 2),
        sizeWidth,
        sizeHeight,
      );
    }
  }

  bool get isDead => _isDead;

  void addLife(double life) {
    this.life += life;
    if (this.life > maxLife) {
      this.life = maxLife;
    }
  }

  void usePositionInWorldToRender() {
    _usePositionInWorld = true;
  }

  void usePositionToRender() {
    _nextFrameUsePosition = true;
  }

  @override
  get positionInWorld {
    if (_usePositionInWorld) return super.positionInWorld;

    return super.positionInWorld = Rect.fromLTWH(
      position.left - gameRef.gameCamera.position.x,
      position.top - gameRef.gameCamera.position.y,
      position.width,
      position.height,
    );
  }

  bool get usePositionInWorld => _usePositionInWorld;

  Rect get rectCollision => getRectCollision(position);
  Rect get rectCollisionInWorld => getRectCollision(positionInWorld);

  @override
  void joystickAction(JoystickActionEvent event) {}

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {}
}
