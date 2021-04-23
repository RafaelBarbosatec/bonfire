import 'dart:math';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
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

  /// Movement speed speed of the Player.
  double speed;

  /// life of the Player
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
          moveUp(speed);
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
          moveDown(speed);
          break;
        case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
          isIdle = false;
          moveDownRight();
          break;
        case JoystickMoveDirectional.MOVE_DOWN_LEFT:
          isIdle = false;
          moveDownLeft();
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

  /// Move player to up
  void moveUp(double speed, {VoidCallback? onCollision}) {
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

  /// Move player to right
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

  /// Move player to down
  void moveDown(double speed, {VoidCallback? onCollision}) {
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

  /// Move player to left
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

  /// Move player to up and left
  void moveUpLeft() {
    final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;
    moveLeft(diagonalSpeed);
    moveUp(diagonalSpeed);
  }

  /// Move player to up and right
  void moveUpRight() {
    final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;
    moveRight(diagonalSpeed);
    moveUp(diagonalSpeed);
  }

  /// Move player to down and right
  void moveDownRight() {
    final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;
    moveRight(diagonalSpeed);
    moveDown(diagonalSpeed);
  }

  /// Move player to down and left
  void moveDownLeft() {
    final diagonalSpeed = this.speed * REDUCTION_SPEED_DIAGONAL;
    moveLeft(diagonalSpeed);
    moveDown(diagonalSpeed);
  }

  void idle() {
    isIdle = true;
  }

  /// Move Playr to direction by radAngle
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
    double innerSpeed = speed * _dtUpdate;
    _positionToMove = Vector2(
      position.x - (position.x % innerSpeed),
      position.y - (position.y % innerSpeed),
    );
  }

  /// Move player to position tapped
  /// Used when uses [TouchToPosition]
  void moveToPosition() {
    if (_positionToMove == null) return;
    bool move = false;

    if (_positionToMove!.x > position.center.dx &&
        _positionToMove!.x - position.center.dx > 1) {
      move = true;
      moveRight(
        speed,
        onCollision: () {
          move = false;
          _positionToMove = null;
        },
      );
    }

    if (_positionToMove != null &&
        _positionToMove!.x < position.center.dx &&
        position.center.dx - _positionToMove!.x > 1) {
      move = true;
      moveLeft(
        speed,
        onCollision: () {
          move = false;
          _positionToMove = null;
        },
      );
    }

    if (_positionToMove != null &&
        _positionToMove!.y > position.center.dy &&
        _positionToMove!.y - position.center.dy > 1) {
      move = true;
      moveDown(
        speed,
        onCollision: () {
          move = false;
          _positionToMove = null;
        },
      );
    }

    if (_positionToMove != null &&
        _positionToMove!.y < position.center.dy &&
        position.center.dy - _positionToMove!.y > 1) {
      move = true;
      moveUp(
        speed,
        onCollision: () {
          move = false;
          _positionToMove = null;
        },
      );
    }

    if (!move) {
      idle();
      isIdle = false;
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
