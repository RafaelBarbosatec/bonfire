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
class SoldierPlayer extends RotationPlayer
    with BlockMovementCollision, Lighting {
  SoldierPlayer(Vector2 position)
      : super(
          position: position,
          size: Vector2(68, 43),
          animIdle: _getSoldierSprite(),
          animRun: _getSoldierSprite(),
        ) {
    setupLighting(
      LightingConfig(
        radius: size.y * 2,
        blurBorder: size.y / 2,
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
  void onJoystickAction(JoystickActionEvent event) {
    if ((event.id == 1 || event.id == LogicalKeyboardKey.space) &&
        event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    super.onJoystickAction(event);
  }

  void actionAttack() {
    Vector2 centerOffset = Vector2.zero();

    switch (lastDirection) {
      case Direction.left:
        centerOffset = Vector2(10, -10);
        break;
      case Direction.right:
        centerOffset = Vector2(-10, 10);
        break;
      case Direction.up:
        centerOffset = Vector2(-4, 20);
        break;
      case Direction.down:
        centerOffset = Vector2(-22, 0);
        break;
      case Direction.upLeft:
        centerOffset = Vector2(20, 20);
        break;
      case Direction.upRight:
        centerOffset = Vector2(6, 30);
        break;
      case Direction.downLeft:
        centerOffset = Vector2(10, 0);
        break;
      case Direction.downRight:
        centerOffset = Vector2(-16, 10);
        break;
    }
    simpleAttackRangeByAngle(
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
      angle: angle,
      size: Vector2(8, 4),
      centerOffset: centerOffset,
      speed: 500,
      animation: Sprite.load('bullet.png').toAnimation(),
      damage: 30,
    );
  }

  @override
  void onDie() {
    removeFromParent();
    super.onDie();
  }

  @override
  Future<void> onLoad() {
    add(
      CircleHitbox(
        radius: size.y / 2,
        position: Vector2(
          12.5,
          0,
        ),
      ),
    );
    return super.onLoad();
  }
}
