import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

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
/// on 28/01/22
class RobotEnemy extends RotationEnemy with ObjectCollision, Lighting {
  RobotEnemy(Vector2 position)
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

  static Future<SpriteAnimation> _getSoldierSprite() async {
    var sprite = await Sprite.load('robot.png');
    return SpriteAnimation.spriteList([sprite], stepTime: 0);
  }

  @override
  void update(double dt) {
    this.seeAndMoveToPlayer(
      closePlayer: (player) {},
      radiusVision: 128,
      margin: 64,
    );
    super.update(dt);
  }
}
