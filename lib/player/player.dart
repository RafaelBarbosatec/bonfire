import 'dart:math';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/mixins/move_to_position_along_the_path.dart';
import 'package:bonfire/util/mixins/movement.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Player extends GameComponent
    with Movement, Attackable, MoveToPositionAlongThePath
    implements JoystickListener {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;

  /// Width of the Player.
  final double width;

  /// Height of the Player.
  final double height;

  /// Movement speed of the Player (pixel per second).
  double speed;

  /// life of the Player
  double life;

  late double maxLife;

  bool _isDead = false;
  double _dtUpdate = 0;
  bool isFocusCamera = true;
  JoystickMoveDirectional _currentDirectional = JoystickMoveDirectional.IDLE;

  Player({
    required Vector2 position,
    required this.width,
    required this.height,
    this.life = 100,
    this.speed = 100,
  }) {
    receivesAttackFrom = ReceivesAttackFromEnum.ENEMY;
    this.position = Rect.fromLTWH(
      position.x,
      position.y,
      width,
      height,
    ).toVector2Rect();

    maxLife = life;
  }

  @override
  void update(double dt) {
    _dtUpdate = dt;
    if (isDead) return;

    final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;

    switch (_currentDirectional) {
      case JoystickMoveDirectional.MOVE_UP:
        moveUp(speed);
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        moveUpLeft(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        moveUpRight(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        moveRight(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        moveDown(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        moveDownRight(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        moveDownLeft(diagonalSpeed, diagonalSpeed);
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        moveLeft(speed);
        break;
      case JoystickMoveDirectional.IDLE:
        idle();
        break;
    }
    super.update(dt);
  }

  /// Move Player to direction by radAngle
  void moveFromAngle(double speed, double angle, {VoidCallback? onCollision}) {
    double nextX = (speed * _dtUpdate) * cos(angle);
    double nextY = (speed * _dtUpdate) * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(
          position.rect.center.dx + nextPoint.dx,
          position.rect.center.dy + nextPoint.dy,
        ) -
        position.rect.center;

    Offset newDiffBase = diffBase;

    Vector2Rect newPosition = position.shift(newDiffBase);

    if (_playerIsCollision(
      displacement: newPosition,
      onlyVisible: isFocusCamera,
    )) {
      onCollision?.call();
      return;
    }

    position = newPosition;
  }

  @override
  void receiveDamage(double damage, dynamic from) {
    if (life > 0) {
      life -= damage;
      if (life <= 0) {
        die();
      }
    }
  }

  /// marks the player as dead
  void die() {
    _isDead = true;
  }

  bool get isDead => _isDead;

  /// increase life in the player
  void addLife(double life) {
    this.life += life;
    if (this.life > maxLife) {
      this.life = maxLife;
    }
  }

  @override
  void joystickAction(JoystickActionEvent event) {}

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    _currentDirectional = event.directional;
  }

  @override
  void moveTo(Vector2 position) {
    this.moveToPositionAlongThePath(position, speed);
  }

  bool _playerIsCollision({
    required Vector2Rect displacement,
    bool onlyVisible = true,
  }) {
    if (this is ObjectCollision) {
      (this as ObjectCollision).setCollisionOnlyVisibleScreen(onlyVisible);
      return (this as ObjectCollision).isCollision(
        displacement: displacement,
      );
    } else {
      return false;
    }
  }
}
