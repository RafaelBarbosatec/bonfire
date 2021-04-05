import 'dart:math';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Player extends GameComponent with Attackable implements JoystickListener {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;

  /// Width of the Player.
  final double width;

  /// Height of the Player.
  final double height;

  double speed;

  double life;
  late double maxLife;

  bool _isDead = false;
  bool isIdle = true;

  double _dtUpdate = 0;

  bool isFocusCamera = true;

  Vector2? _positionToMove;

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
    if (_positionToMove != null) {
      moveToPosition();
    } else {
      switch (_currentDirectional) {
        case JoystickMoveDirectional.MOVE_UP:
          isIdle = false;
          moveTop(speed);
          break;
        case JoystickMoveDirectional.MOVE_UP_LEFT:
          isIdle = false;
          moveUpLeft();
          break;
        case JoystickMoveDirectional.MOVE_UP_RIGHT:
          isIdle = false;
          moveUpRight();
          break;
        case JoystickMoveDirectional.MOVE_RIGHT:
          isIdle = false;
          moveRight(speed);
          break;
        case JoystickMoveDirectional.MOVE_DOWN:
          isIdle = false;
          moveBottom(speed);
          break;
        case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
          isIdle = false;
          moveBottomRight();
          break;
        case JoystickMoveDirectional.MOVE_DOWN_LEFT:
          isIdle = false;
          moveBottomLeft();
          break;
        case JoystickMoveDirectional.MOVE_LEFT:
          isIdle = false;
          moveLeft(speed);
          break;
        case JoystickMoveDirectional.IDLE:
          idle();
          break;
      }
    }
    super.update(dt);
  }

  void moveTop(double speed, {VoidCallback? onCollision}) {
    double innerSpeed = speed * _dtUpdate;

    Vector2Rect displacement = position.translate(0, (-innerSpeed));

    if (_playerIsCollision(
      displacement: displacement,
      onlyVisible: isFocusCamera,
    )) {
      onCollision?.call();
      return;
    }
    position = displacement;
  }

  void moveRight(double speed, {VoidCallback? onCollision}) {
    double innerSpeed = speed * _dtUpdate;

    Vector2Rect displacement = position.translate(innerSpeed, 0);

    if (_playerIsCollision(
      displacement: displacement,
      onlyVisible: isFocusCamera,
    )) {
      onCollision?.call();
      return;
    }

    position = displacement;
  }

  void moveBottom(double speed, {VoidCallback? onCollision}) {
    double innerSpeed = speed * _dtUpdate;

    Vector2Rect displacement = position.translate(0, innerSpeed);

    if (_playerIsCollision(
      displacement: displacement,
      onlyVisible: isFocusCamera,
    )) {
      onCollision?.call();
      return;
    }

    position = displacement;
  }

  void moveLeft(double speed, {VoidCallback? onCollision}) {
    double innerSpeed = speed * _dtUpdate;

    Vector2Rect displacement = position.translate(-innerSpeed, 0);

    if (_playerIsCollision(
      displacement: displacement,
      onlyVisible: isFocusCamera,
    )) {
      onCollision?.call();
      return;
    }

    position = displacement;
  }

  void moveUpLeft() {
    final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;
    moveLeft(diagonalSpeed);
    moveTop(diagonalSpeed);
  }

  void moveUpRight() {
    final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;
    moveRight(diagonalSpeed);
    moveTop(diagonalSpeed);
  }

  void moveBottomRight() {
    final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;
    moveRight(diagonalSpeed);
    moveBottom(diagonalSpeed);
  }

  void moveBottomLeft() {
    final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;
    moveLeft(diagonalSpeed);
    moveBottom(diagonalSpeed);
  }

  void idle() {
    isIdle = true;
  }

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

  void die() {
    _isDead = true;
  }

  bool get isDead => _isDead;

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
    _positionToMove = position;
  }

  void moveToPosition() {
    if (_positionToMove == null) return;
    bool move = false;

    if (_positionToMove!.x > position.center.dx &&
        _positionToMove!.x - position.center.dx > 1) {
      move = true;
      moveRight(
        speed,
        onCollision: () {
          _positionToMove = null;
        },
      );
    }

    if (_positionToMove!.x < position.center.dx &&
        position.center.dx - _positionToMove!.x > 1) {
      move = true;
      moveLeft(
        speed,
        onCollision: () {
          _positionToMove = null;
          return;
        },
      );
    }
    if (_positionToMove == null) return;
    if (_positionToMove!.y > position.center.dy &&
        _positionToMove!.y - position.center.dy > 1) {
      move = true;
      moveBottom(
        speed,
        onCollision: () {
          _positionToMove = null;
          return;
        },
      );
    }
    if (_positionToMove == null) return;
    if (_positionToMove!.y < position.center.dy &&
        position.center.dy - _positionToMove!.y > 1) {
      move = true;
      moveTop(
        speed,
        onCollision: () {
          _positionToMove = null;
          return;
        },
      );
    }
    if (!move) {
      idle();
      _positionToMove = null;
    }
  }

  bool _playerIsCollision({
    required Vector2Rect displacement,
    bool onlyVisible = true,
  }) {
    var collision = false;
    if (this is ObjectCollision) {
      (this as ObjectCollision).setCollisionOnlyVisibleScreen(onlyVisible);
      collision = (this as ObjectCollision).isCollision(
        displacement: displacement,
      );
    }

    return collision;
  }
}
