import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/mixins/move_to_position_along_the_path.dart';
import 'package:bonfire/util/mixins/movement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Player extends GameComponent
    with Movement, Attackable, MoveToPositionAlongThePath
    implements JoystickListener {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;

  bool _isDead = false;
  bool isFocusCamera = true;
  JoystickMoveDirectional _currentDirectional = JoystickMoveDirectional.IDLE;

  Player({
    required Vector2 position,
    required double width,
    required double height,
    double life = 100,
    double speed = 100,
  }) {
    this.speed = speed;
    receivesAttackFrom = ReceivesAttackFromEnum.ENEMY;
    initialLife(life);
    this.position = Rect.fromLTWH(
      position.x,
      position.y,
      width,
      height,
    ).toVector2Rect();
  }

  @override
  void update(double dt) {
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
        if (!isIdle) {
          idle();
        }
        break;
    }
    super.update(dt);
  }

  @override
  void receiveDamage(double damage, dynamic from) {
    super.receiveDamage(damage, from);
    if (life <= 0) {
      die();
    }
  }

  @override
  void idle() {
    _currentDirectional = JoystickMoveDirectional.IDLE;
    super.idle();
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
}
