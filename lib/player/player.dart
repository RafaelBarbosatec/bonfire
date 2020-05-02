import 'dart:ui';

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

  double _dtUpdate = 0;

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
    if (gameRef != null && gameRef.showCollisionArea) {
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
    _dtUpdate = dt;
  }

  void moveTop(double speed) {
    if (position.top <= 0) return;

    double innerSpeed = speed * _dtUpdate;

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

    double innerSpeed = speed * _dtUpdate;

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

    double innerSpeed = speed * _dtUpdate;

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

    double innerSpeed = speed * _dtUpdate;

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

  void receiveDamage(double damage) {
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
  void joystickAction(int action) {}

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {}
}
