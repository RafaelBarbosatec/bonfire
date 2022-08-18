import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 27/01/22
class SoldierPlayer extends RotationPlayer with ObjectCollision, Lighting {
  SoldierPlayer(Vector2 position)
      : super(
          position: position,
          size: Vector2(68, 43),
          animIdle: _getSoldierSprite(),
          animRun: _getSoldierSprite(),
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.circle(
            radius: 21.5,
            align: Vector2(
              12.5,
              0,
            ),
          ),
        ],
      ),
    );
    setupLighting(
      LightingConfig(
        radius: size.y * 2,
        color: Colors.yellow.withOpacity(0.3),
        type: LightingType.arc(
          endRadAngle: (2 * pi) / 6,
          isCenter: true,
        ),
        useComponentAngle: true,
      ),
    );
  }

  static Future<SpriteAnimation> _getSoldierSprite() {
    return Sprite.load('soldier.png').toAnimation();
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    speed = 150 * event.intensity;
    super.joystickChangeDirectional(event);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if ((event.id == 1 || event.id == LogicalKeyboardKey.space.keyId) &&
        event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    super.joystickAction(event);
  }

  void actionAttack() {
    Vector2 centerOffset = Vector2.zero();
    switch (lastDirection) {
      case Direction.left:
        centerOffset = Vector2(0, -10);
        break;
      case Direction.right:
        centerOffset = Vector2(0, 10);
        break;
      case Direction.up:
        centerOffset = Vector2(10, 0);
        break;
      case Direction.down:
        centerOffset = Vector2(-10, 0);
        break;
      case Direction.upLeft:
        centerOffset = Vector2(12, 0);
        break;
      case Direction.upRight:
        centerOffset = Vector2(12, 0);
        break;
      case Direction.downLeft:
        centerOffset = Vector2(-12, 0);
        break;
      case Direction.downRight:
        centerOffset = Vector2(-12, 0);
        break;
    }
    simpleAttackRangeByAngle(
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
      angle: angle,
      size: Vector2(8, 4),
      centerOffset: centerOffset,
      marginFromOrigin: 8,
      speed: 500,
      animation: Sprite.load('bullet.png').toAnimation(),
      damage: 30,
    );
  }

  @override
  void die() {
    removeFromParent();
    super.die();
  }
}
