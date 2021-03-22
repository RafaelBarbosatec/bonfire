import 'dart:math';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/priority_layer.dart';
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
  double maxLife;

  bool _isDead = false;

  double _dtUpdate = 0;

  bool isFocusCamera = true;

  Player({
    @required Vector2 position,
    this.width = 32,
    this.height = 32,
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
    super.update(dt);
  }

  void moveTop(double speed, {VoidCallback onCollision}) {
    double innerSpeed = speed * _dtUpdate;

    Vector2Rect displacement = position.translate(0, (-innerSpeed));

    if (_playerIsCollision(
        displacement: displacement, onlyVisible: isFocusCamera)) {
      onCollision?.call();
      return;
    }
    position = displacement;
  }

  void moveRight(double speed, {VoidCallback onCollision}) {
    double innerSpeed = speed * _dtUpdate;

    Vector2Rect displacement = position.translate(innerSpeed, 0);

    if (_playerIsCollision(
        displacement: displacement, onlyVisible: isFocusCamera)) {
      onCollision?.call();
      return;
    }

    position = displacement;
  }

  void moveBottom(double speed, {VoidCallback onCollision}) {
    double innerSpeed = speed * _dtUpdate;

    Vector2Rect displacement = position.translate(0, innerSpeed);

    if (_playerIsCollision(
        displacement: displacement, onlyVisible: isFocusCamera)) {
      onCollision?.call();
      return;
    }

    position = displacement;
  }

  void moveLeft(double speed, {VoidCallback onCollision}) {
    double innerSpeed = speed * _dtUpdate;

    Vector2Rect displacement = position.translate(-innerSpeed, 0);

    if (_playerIsCollision(
        displacement: displacement, onlyVisible: isFocusCamera)) {
      onCollision?.call();
      return;
    }

    position = displacement;
  }

  void moveFromAngle(double speed, double angle, {VoidCallback onCollision}) {
    double nextX = (speed * _dtUpdate) * cos(angle);
    double nextY = (speed * _dtUpdate) * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(position.rect.center.dx + nextPoint.dx,
            position.rect.center.dy + nextPoint.dy) -
        position.rect.center;

    Offset newDiffBase = diffBase;

    Vector2Rect newPosition = position.shift(newDiffBase);

    if (_playerIsCollision(
        displacement: newPosition, onlyVisible: isFocusCamera)) {
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
  void joystickChangeDirectional(JoystickDirectionalEvent event) {}

  @override
  int get priority => PriorityLayer.PLAYER;

  @override
  void moveTo(Vector2 position) {}

  bool _playerIsCollision({Vector2Rect displacement, bool onlyVisible}) {
    var collision = false;
    if (this is ObjectCollision) {
      (this as ObjectCollision).setCollisionOnlyVisibleScreen(onlyVisible);
      collision =
          (this as ObjectCollision).isCollision(displacement: displacement);
    }

    return collision;
  }
}
