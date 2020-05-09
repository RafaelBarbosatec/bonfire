import 'dart:math';

import 'package:bonfire/player/rotation_player.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/objects/animated_object_once.dart';
import 'package:bonfire/util/objects/flying_attack_angle_object.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/widgets.dart';

extension RotationPlayerExtensions on RotationPlayer {
  void simpleAttackRange({
    @required FlameAnimation.Animation animationTop,
    @required FlameAnimation.Animation animationDestroy,
    @required double width,
    @required double height,
    int id,
    double speed = 150,
    double damage = 1,
    bool withCollision = true,
    VoidCallback destroy,
    Collision collision,
  }) {
    if (isDead || this.currentRadAngle == 0) return;

    double nextX = this.height * cos(this.currentRadAngle);
    double nextY = this.height * sin(this.currentRadAngle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(this.positionInWorld.center.dx + nextPoint.dx,
            this.positionInWorld.center.dy + nextPoint.dy) -
        this.positionInWorld.center;

    Rect position = this.positionInWorld.shift(diffBase);
    gameRef.add(FlyingAttackAngleObject(
      id: id,
      initPosition: Position(position.left, position.top),
      radAngle: this.currentRadAngle,
      width: width,
      height: height,
      damage: damage,
      speed: speed,
      damageInPlayer: false,
      collision: collision,
      withCollision: withCollision,
      damageInEnemy: true,
      destroyedObject: destroy,
      flyAnimation: animationTop,
      destroyAnimation: animationDestroy,
    ));
  }

  void simpleAttackMelee({
    @required FlameAnimation.Animation attackEffectTopAnim,
    @required double damage,
    int id,
    double heightArea = 32,
    double widthArea = 32,
    bool withPush = true,
  }) {
    if (isDead) return;

    double nextX = this.height * cos(this.currentRadAngle);
    double nextY = this.height * sin(this.currentRadAngle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(this.positionInWorld.center.dx + nextPoint.dx,
            this.positionInWorld.center.dy + nextPoint.dy) -
        this.positionInWorld.center;

    Rect positionAttack = this.positionInWorld.shift(diffBase);

    gameRef.add(AnimatedObjectOnce(
      animation: attackEffectTopAnim,
      position: positionAttack,
      rotateRadAngle: this.currentRadAngle,
    ));

    gameRef.visibleEnemies().forEach((enemy) {
      if (enemy.rectCollisionInWorld.overlaps(positionAttack)) {
        enemy.receiveDamage(damage, id);
        Rect rectAfterPush = enemy.position.translate(diffBase.dx, diffBase.dy);
        if (withPush && !enemy.isCollision(rectAfterPush, this.gameRef)) {
          enemy.translate(diffBase.dx, diffBase.dy);
        }
      }
    });
  }
}
