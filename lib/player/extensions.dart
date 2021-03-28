import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:bonfire/objects/flying_attack_angle_object.dart';
import 'package:bonfire/objects/flying_attack_object.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/text_damage_component.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension PlayerExtensions on Player {
  void showDamage(
    double damage, {
    TextConfig config,
    double initVelocityTop = -5,
    double gravity = 0.5,
    double maxDownSize = 20,
    bool onlyUp = false,
    DirectionTextDamage direction = DirectionTextDamage.RANDOM,
  }) {
    gameRef.add(
      TextDamageComponent(
        damage.toInt().toString(),
        Position(
          position.center.dx,
          position.top,
        ),
        config: config ??
            TextConfig(
              fontSize: 14,
              color: Colors.red,
            ),
        initVelocityTop: initVelocityTop,
        gravity: gravity,
        direction: direction,
        onlyUp: onlyUp,
        maxDownSize: maxDownSize,
      ),
    );
  }

  void seeEnemy({
    Function(List<Enemy>) observed,
    Function() notObserved,
    double radiusVision = 32,
  }) {
    if (isDead || this.position == null) return;

    var enemiesInLife = this.gameRef.visibleEnemies();
    if (enemiesInLife.isEmpty) {
      if (notObserved != null) notObserved();
      return;
    }

    double visionWidth = radiusVision * 2;
    double visionHeight = radiusVision * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      this.position.center.dx - radiusVision,
      this.position.center.dy - radiusVision,
      visionWidth,
      visionHeight,
    );

    List<Enemy> enemiesObserved = enemiesInLife
        .where((enemy) =>
            enemy.position != null && fieldOfVision.overlaps(enemy.position))
        .toList();

    if (enemiesObserved.isNotEmpty) {
      if (observed != null) observed(enemiesObserved);
    } else {
      if (notObserved != null) notObserved();
    }
  }

  void simpleAttackRangeByAngle({
    @required FlameAnimation.Animation animationTop,
    @required double width,
    @required double height,
    @required double radAngleDirection,
    FlameAnimation.Animation animationDestroy,
    dynamic id,
    double speed = 150,
    double damage = 1,
    bool withCollision = true,
    bool collisionOnlyVisibleObjects = true,
    VoidCallback destroy,
    CollisionConfig collision,
    LightingConfig lightingConfig,
  }) {
    if (isDead) return;

    double angle = radAngleDirection;
    double nextX = this.height * cos(angle);
    double nextY = this.height * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(this.position.center.dx + nextPoint.dx,
            this.position.center.dy + nextPoint.dy) -
        this.position.center;

    Rect position = this.position.shift(diffBase);
    gameRef.add(FlyingAttackAngleObject(
      id: id,
      initPosition: Position(position.left, position.top),
      radAngle: angle,
      width: width,
      height: height,
      damage: damage,
      speed: speed,
      damageInPlayer: false,
      collision: collision,
      withCollision: withCollision,
      destroyedObject: destroy,
      flyAnimation: animationTop,
      destroyAnimation: animationDestroy,
      lightingConfig: lightingConfig,
      collisionOnlyVisibleObjects: collisionOnlyVisibleObjects,
    ));
  }

  void simpleAttackRangeByDirection({
    @required FlameAnimation.Animation animationRight,
    @required FlameAnimation.Animation animationLeft,
    @required FlameAnimation.Animation animationTop,
    @required FlameAnimation.Animation animationBottom,
    FlameAnimation.Animation animationDestroy,
    @required double width,
    @required double height,
    @required Direction direction,
    dynamic id,
    double speed = 150,
    double damage = 1,
    bool withCollision = true,
    bool collisionOnlyVisibleObjects = true,
    VoidCallback destroy,
    CollisionConfig collision,
    LightingConfig lightingConfig,
  }) {
    if (isDead) return;

    Position startPosition;
    FlameAnimation.Animation attackRangeAnimation;

    Direction attackDirection = direction;

    Rect rectBase = (this is ObjectCollision)
        ? (this as ObjectCollision).rectCollision
        : position;

    switch (attackDirection) {
      case Direction.left:
        if (animationLeft != null) attackRangeAnimation = animationLeft;
        startPosition = Position(
          rectBase.left - width,
          (rectBase.top + (rectBase.height - height) / 2),
        );
        break;
      case Direction.right:
        if (animationRight != null) attackRangeAnimation = animationRight;
        startPosition = Position(
          rectBase.right,
          (rectBase.top + (rectBase.height - height) / 2),
        );
        break;
      case Direction.top:
        if (animationTop != null) attackRangeAnimation = animationTop;
        startPosition = Position(
          (rectBase.left + (rectBase.width - width) / 2),
          rectBase.top - height,
        );
        break;
      case Direction.bottom:
        if (animationBottom != null) attackRangeAnimation = animationBottom;
        startPosition = Position(
          (rectBase.left + (rectBase.width - width) / 2),
          rectBase.bottom,
        );
        break;
      case Direction.topLeft:
        if (animationLeft != null) attackRangeAnimation = animationLeft;
        startPosition = Position(
          rectBase.left - width,
          (rectBase.top + (rectBase.height - height) / 2),
        );
        break;
      case Direction.topRight:
        if (animationRight != null) attackRangeAnimation = animationRight;
        startPosition = Position(
          rectBase.right,
          (rectBase.top + (rectBase.height - height) / 2),
        );
        break;
      case Direction.bottomLeft:
        if (animationLeft != null) attackRangeAnimation = animationLeft;
        startPosition = Position(
          rectBase.left - width,
          (rectBase.top + (rectBase.height - height) / 2),
        );
        break;
      case Direction.bottomRight:
        if (animationRight != null) attackRangeAnimation = animationRight;
        startPosition = Position(
          rectBase.right,
          (rectBase.top + (rectBase.height - height) / 2),
        );
        break;
    }

    gameRef.add(
      FlyingAttackObject(
        id: id,
        direction: attackDirection,
        flyAnimation: attackRangeAnimation,
        destroyAnimation: animationDestroy,
        initPosition: startPosition,
        height: height,
        width: width,
        damage: damage,
        speed: speed,
        attackFrom: AttackFromEnum.PLAYER,
        destroyedObject: destroy,
        withDecorationCollision: withCollision,
        collision: collision,
        lightingConfig: lightingConfig,
      ),
    );
  }

  void simpleAttackMeleeByDirection({
    FlameAnimation.Animation animationRight,
    FlameAnimation.Animation animationBottom,
    FlameAnimation.Animation animationLeft,
    FlameAnimation.Animation animationTop,
    @required double damage,
    @required Direction direction,
    dynamic id,
    double heightArea = 32,
    double widthArea = 32,
    bool withPush = true,
    double sizePush,
  }) {
    if (isDead) return;

    Rect positionAttack;
    FlameAnimation.Animation anim;
    double pushLeft = 0;
    double pushTop = 0;
    Direction attackDirection = direction;

    Rect rectBase = (this is ObjectCollision)
        ? (this as ObjectCollision).rectCollision
        : position;

    switch (attackDirection) {
      case Direction.top:
        positionAttack = Rect.fromLTWH(
          this.position.left + (this.width - widthArea) / 2,
          rectBase.top - heightArea,
          widthArea,
          heightArea,
        );
        if (animationTop != null) anim = animationTop;
        pushTop = (sizePush ?? heightArea) * -1;
        break;
      case Direction.right:
        positionAttack = Rect.fromLTWH(
          rectBase.right,
          this.position.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? widthArea);
        break;
      case Direction.bottom:
        positionAttack = Rect.fromLTWH(
          this.position.left + (this.width - widthArea) / 2,
          rectBase.bottom,
          widthArea,
          heightArea,
        );
        if (animationBottom != null) anim = animationBottom;
        pushTop = (sizePush ?? heightArea);
        break;
      case Direction.left:
        positionAttack = Rect.fromLTWH(
          rectBase.left - widthArea,
          this.position.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? widthArea) * -1;
        break;
      case Direction.topLeft:
        positionAttack = Rect.fromLTWH(
          rectBase.left - widthArea,
          this.position.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? widthArea) * -1;
        break;
      case Direction.topRight:
        positionAttack = Rect.fromLTWH(
          rectBase.right,
          this.position.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? widthArea);
        break;
      case Direction.bottomLeft:
        positionAttack = Rect.fromLTWH(
          rectBase.left - widthArea,
          this.position.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? widthArea) * -1;
        break;
      case Direction.bottomRight:
        positionAttack = Rect.fromLTWH(
          rectBase.right,
          this.position.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? widthArea);
        break;
    }

    if (anim != null) {
      gameRef.add(AnimatedObjectOnce(
        animation: anim,
        position: positionAttack,
      ));
    }

    gameRef.attackables().where((a) {
      return a.receivesAttackFromPlayer() &&
          a.rectAttackable().overlaps(positionAttack);
    }).forEach(
      (enemy) {
        enemy.receiveDamage(damage, id);
        Rect rectAfterPush = enemy.position.translate(pushLeft, pushTop);
        if (withPush &&
            (enemy is ObjectCollision &&
                !(enemy as ObjectCollision)
                    .isCollision(displacement: rectAfterPush))) {
          enemy.translate(pushLeft, pushTop);
        }
      },
    );
  }

  void simpleAttackMeleeByAngle({
    @required FlameAnimation.Animation animationTop,
    @required double damage,
    @required double radAngleDirection,
    dynamic id,
    double heightArea = 32,
    double widthArea = 32,
    bool withPush = true,
  }) {
    if (isDead) return;

    double angle = radAngleDirection;

    double nextX = this.height * cos(angle);
    double nextY = this.height * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(this.position.center.dx + nextPoint.dx,
            this.position.center.dy + nextPoint.dy) -
        this.position.center;

    Rect positionAttack = this.position.shift(diffBase);

    gameRef.add(AnimatedObjectOnce(
      animation: animationTop,
      position: positionAttack,
      rotateRadAngle: angle,
    ));

    gameRef
        .attackables()
        .where((a) =>
            a.receivesAttackFromPlayer() &&
            a.rectAttackable().overlaps(positionAttack))
        .forEach((enemy) {
      enemy.receiveDamage(damage, id);
      Rect rectAfterPush = enemy.position.translate(diffBase.dx, diffBase.dy);
      if (withPush &&
          (enemy is ObjectCollision &&
              !(enemy as ObjectCollision)
                  .isCollision(displacement: rectAfterPush))) {
        enemy.translate(diffBase.dx, diffBase.dy);
      }
    });
  }
}
