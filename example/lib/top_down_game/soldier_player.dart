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
    simpleAttackRangeByAngle(
      angle: angle,
      size: Vector2(8, 4),
      speed: 500,
      animation: Sprite.load('bullet.png').toAnimation(),
      damage: 30,
    );
  }
}
