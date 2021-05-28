import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:bonfire/objects/flying_attack_angle_object.dart';
import 'package:bonfire/objects/flying_attack_object.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/text_damage_component.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension PlayerExtensions on Player {
  /// Add in the game a text with animation representing damage received
  void showDamage(
    double damage, {
    TextPaintConfig? config,
    double initVelocityTop = -5,
    double gravity = 0.5,
    double maxDownSize = 20,
    bool onlyUp = false,
    DirectionTextDamage direction = DirectionTextDamage.RANDOM,
  }) {
    gameRef.add(
      TextDamageComponent(
        damage.toInt().toString(),
        Vector2(
          position.rect.center.dx,
          position.rect.top,
        ),
        config: config ??
            TextPaintConfig(
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

  /// This method we notify when detect the enemy when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  void seeEnemy({
    required Function(List<Enemy>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    if (isDead) return;

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
        .where((enemy) => fieldOfVision.overlaps(enemy.position.rect))
        .toList();

    if (enemiesObserved.isNotEmpty) {
      observed(enemiesObserved);
    } else {
      notObserved?.call();
    }
  }

  /// Execute the ranged attack using a component with animation
  void simpleAttackRangeByAngle({
    required Future<SpriteAnimation> animationTop,
    required double width,
    required double height,
    required double radAngleDirection,
    Future<SpriteAnimation>? animationDestroy,
    dynamic id,
    double speed = 150,
    double damage = 1,
    bool withCollision = true,
    VoidCallback? destroy,
    CollisionConfig? collision,
    LightingConfig? lightingConfig,
  }) {
    if (isDead) return;

    double angle = radAngleDirection;
    double nextX = this.height * cos(angle);
    double nextY = this.height * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(this.position.center.dx + nextPoint.dx,
            this.position.center.dy + nextPoint.dy) -
        this.position.center;

    Vector2Rect position = this.position.shift(diffBase);
    gameRef.add(FlyingAttackAngleObject(
      id: id,
      position: position.position,
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
    ));
  }

  /// Execute the ranged attack using a component with animation
  void simpleAttackRangeByDirection({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    required Future<SpriteAnimation> animationTop,
    required Future<SpriteAnimation> animationBottom,
    Future<SpriteAnimation>? animationDestroy,
    required double width,
    required double height,
    required Direction direction,
    dynamic id,
    double speed = 150,
    double damage = 1,
    bool withCollision = true,
    bool collisionOnlyVisibleObjects = true,
    VoidCallback? destroy,
    CollisionConfig? collision,
    LightingConfig? lightingConfig,
  }) {
    if (isDead) return;

    Vector2 startPosition;
    Future<SpriteAnimation> attackRangeAnimation;

    Direction attackDirection = direction;

    Vector2Rect rectBase = (this.isObjectCollision())
        ? (this as ObjectCollision).rectCollision
        : position;

    switch (attackDirection) {
      case Direction.left:
        attackRangeAnimation = animationLeft;
        startPosition = Vector2(
          rectBase.rect.left - width,
          (rectBase.rect.top + (rectBase.rect.height - height) / 2),
        );
        break;
      case Direction.right:
        attackRangeAnimation = animationRight;
        startPosition = Vector2(
          rectBase.rect.right,
          (rectBase.rect.top + (rectBase.rect.height - height) / 2),
        );
        break;
      case Direction.up:
        attackRangeAnimation = animationTop;
        startPosition = Vector2(
          (rectBase.rect.left + (rectBase.rect.width - width) / 2),
          rectBase.rect.top - height,
        );
        break;
      case Direction.down:
        attackRangeAnimation = animationBottom;
        startPosition = Vector2(
          (rectBase.rect.left + (rectBase.rect.width - width) / 2),
          rectBase.rect.bottom,
        );
        break;
      case Direction.upLeft:
        attackRangeAnimation = animationLeft;
        startPosition = Vector2(
          rectBase.rect.left - width,
          (rectBase.rect.top + (rectBase.rect.height - height) / 2),
        );
        break;
      case Direction.upRight:
        attackRangeAnimation = animationRight;
        startPosition = Vector2(
          rectBase.rect.right,
          (rectBase.rect.top + (rectBase.rect.height - height) / 2),
        );
        break;
      case Direction.downLeft:
        attackRangeAnimation = animationLeft;
        startPosition = Vector2(
          rectBase.rect.left - width,
          (rectBase.rect.top + (rectBase.rect.height - height) / 2),
        );
        break;
      case Direction.downRight:
        attackRangeAnimation = animationRight;
        startPosition = Vector2(
          rectBase.rect.right,
          (rectBase.rect.top + (rectBase.rect.height - height) / 2),
        );
        break;
    }

    gameRef.add(
      FlyingAttackObject(
        id: id,
        direction: attackDirection,
        flyAnimation: attackRangeAnimation,
        destroyAnimation: animationDestroy,
        position: startPosition,
        height: height,
        width: width,
        damage: damage,
        speed: speed,
        attackFrom: AttackFromEnum.PLAYER,
        onDestroyedObject: destroy,
        withDecorationCollision: withCollision,
        collision: collision,
        lightingConfig: lightingConfig,
      ),
    );
  }

  ///Execute simple attack melee using animation
  void simpleAttackMeleeByDirection({
    Future<SpriteAnimation>? animationRight,
    Future<SpriteAnimation>? animationBottom,
    Future<SpriteAnimation>? animationLeft,
    Future<SpriteAnimation>? animationTop,
    dynamic id,
    required double damage,
    required Direction direction,
    required double height,
    required double width,
    bool withPush = true,
    double? sizePush,
  }) {
    if (isDead) return;

    Rect positionAttack;
    Future<SpriteAnimation>? anim;
    double pushLeft = 0;
    double pushTop = 0;
    Direction attackDirection = direction;

    Vector2Rect rectBase = (this.isObjectCollision())
        ? (this as ObjectCollision).rectCollision
        : position;

    switch (attackDirection) {
      case Direction.up:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.center.dx - width / 2,
          rectBase.rect.top - height,
          width,
          height,
        );
        if (animationTop != null) anim = animationTop;
        pushTop = (sizePush ?? height) * -1;
        break;
      case Direction.right:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.right,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? width);
        break;
      case Direction.down:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.center.dx - width / 2,
          rectBase.rect.bottom,
          width,
          height,
        );
        if (animationBottom != null) anim = animationBottom;
        pushTop = (sizePush ?? height);
        break;
      case Direction.left:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.left - width,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? width) * -1;
        break;
      case Direction.upLeft:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.left - width,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? width) * -1;
        break;
      case Direction.upRight:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.right,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? width);
        break;
      case Direction.downLeft:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.left - width,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? width) * -1;
        break;
      case Direction.downRight:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.right,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? width);
        break;
    }

    if (anim != null) {
      gameRef.add(AnimatedObjectOnce(
        animation: anim,
        position: positionAttack.toVector2Rect(),
      ));
    }

    gameRef.visibleAttackables().where((a) {
      return a.receivesAttackFromPlayer() &&
          a.rectAttackable().rect.overlaps(positionAttack);
    }).forEach(
      (enemy) {
        enemy.receiveDamage(damage, id);
        Vector2Rect rectAfterPush = enemy.position.translate(pushLeft, pushTop);
        if (withPush &&
            (enemy is ObjectCollision &&
                !(enemy as ObjectCollision)
                    .isCollision(displacement: rectAfterPush))) {
          enemy.translate(pushLeft, pushTop);
        }
      },
    );
  }

  ///Execute simple attack melee using animation
  void simpleAttackMeleeByAngle({
    required Future<SpriteAnimation> animationTop,
    required double damage,
    required double radAngleDirection,
    dynamic id,
    required double height,
    required double width,
    bool withPush = true,
  }) {
    if (isDead) return;

    double angle = radAngleDirection;

    double nextX = height * cos(angle);
    double nextY = width * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(
          this.position.center.dx + nextPoint.dx,
          this.position.center.dy + nextPoint.dy,
        ) -
        this.position.center;

    Vector2Rect positionAttack = this.position.shift(diffBase);

    gameRef.add(AnimatedObjectOnce(
      animation: animationTop,
      position: positionAttack,
      rotateRadAngle: angle,
    ));

    gameRef
        .visibleAttackables()
        .where((a) =>
            a.receivesAttackFromPlayer() &&
            a.rectAttackable().overlaps(positionAttack))
        .forEach((enemy) {
      enemy.receiveDamage(damage, id);
      Vector2Rect rectAfterPush =
          enemy.position.translate(diffBase.dx, diffBase.dy);
      if (withPush &&
          (enemy is ObjectCollision &&
              !(enemy as ObjectCollision)
                  .isCollision(displacement: rectAfterPush))) {
        enemy.translate(diffBase.dx, diffBase.dy);
      }
    });
  }
}
