import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/text_damage.dart';
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
    bool onlyUp = false,
    DirectionTextDamage direction = DirectionTextDamage.RANDOM,
  }) {
    gameRef.addLater(
      TextDamage(
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
      ),
    );
  }

  void seeEnemy({
    Function(List<Enemy>) observed,
    Function() notObserved,
    int visionCells = 3,
    int interval = 500,
  }) {
    if (isDead || this.position == null) return;

    var enemiesInLife = this.gameRef.visibleEnemies();
    if (enemiesInLife.isEmpty) {
      if (notObserved != null) notObserved();
      return;
    }

    double visionWidth = position.width * visionCells * 2;
    double visionHeight = position.height * visionCells * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      position.left - (visionWidth / 2),
      position.top - (visionHeight / 2),
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
    int id,
    double speed = 150,
    double damage = 1,
    bool withCollision = true,
    bool collisionOnlyVisibleObjects = true,
    VoidCallback destroy,
    Collision collision,
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
    gameRef.addLater(FlyingAttackAngleObject(
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
      damageInEnemy: true,
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
    @required FlameAnimation.Animation animationDestroy,
    @required double width,
    @required double height,
    @required Direction direction,
    int id,
    double speed = 150,
    double damage = 1,
    bool withCollision = true,
    bool collisionOnlyVisibleObjects = true,
    VoidCallback destroy,
    Collision collision,
    LightingConfig lightingConfig,
  }) {
    if (isDead) return;

    Position startPosition;
    FlameAnimation.Animation attackRangeAnimation;

    Direction attackDirection = direction;

    switch (attackDirection) {
      case Direction.left:
        if (animationLeft != null) attackRangeAnimation = animationLeft;
        startPosition = Position(
          this.rectCollision.left - width,
          (this.rectCollision.top + (this.rectCollision.height - height) / 2),
        );
        break;
      case Direction.right:
        if (animationRight != null) attackRangeAnimation = animationRight;
        startPosition = Position(
          this.rectCollision.right,
          (this.rectCollision.top + (this.rectCollision.height - height) / 2),
        );
        break;
      case Direction.top:
        if (animationTop != null) attackRangeAnimation = animationTop;
        startPosition = Position(
          (this.rectCollision.left + (this.rectCollision.width - width) / 2),
          this.rectCollision.top - height,
        );
        break;
      case Direction.bottom:
        if (animationBottom != null) attackRangeAnimation = animationBottom;
        startPosition = Position(
          (this.rectCollision.left + (this.rectCollision.width - width) / 2),
          this.rectCollision.bottom,
        );
        break;
    }

    gameRef.addLater(
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
        damageInPlayer: false,
        destroyedObject: destroy,
        withCollision: withCollision,
        collision: collision,
        lightingConfig: lightingConfig,
        collisionOnlyVisibleObjects: collisionOnlyVisibleObjects,
      ),
    );
  }

  void simpleAttackMeleeByDirection({
    @required FlameAnimation.Animation animationRight,
    @required FlameAnimation.Animation animationBottom,
    @required FlameAnimation.Animation animationLeft,
    @required FlameAnimation.Animation animationTop,
    @required double damage,
    @required Direction direction,
    int id,
    double heightArea = 32,
    double widthArea = 32,
    bool withPush = true,
  }) {
    if (isDead) return;

    Rect positionAttack;
    FlameAnimation.Animation anim = animationRight;
    double pushLeft = 0;
    double pushTop = 0;
    Direction attackDirection = direction;
    switch (attackDirection) {
      case Direction.top:
        positionAttack = Rect.fromLTWH(
            position.left, position.top - heightArea, widthArea, heightArea);
        if (animationTop != null) anim = animationTop;
        pushTop = heightArea * -1;
        break;
      case Direction.right:
        positionAttack = Rect.fromLTWH(
            position.left + widthArea, position.top, widthArea, heightArea);
        if (animationRight != null) anim = animationRight;
        pushLeft = widthArea;
        break;
      case Direction.bottom:
        positionAttack = Rect.fromLTWH(
            position.left, position.top + heightArea, widthArea, heightArea);
        if (animationBottom != null) anim = animationBottom;
        pushTop = heightArea;
        break;
      case Direction.left:
        positionAttack = Rect.fromLTWH(
            position.left - widthArea, position.top, widthArea, heightArea);
        if (animationLeft != null) anim = animationLeft;
        pushLeft = widthArea * -1;
        break;
    }

    gameRef.addLater(AnimatedObjectOnce(
      animation: anim,
      position: positionAttack,
    ));

    gameRef
        .visibleEnemies()
        .where((enemy) => enemy.rectCollision.overlaps(positionAttack))
        .forEach((enemy) {
      enemy.receiveDamage(damage, id);
      Rect rectAfterPush = enemy.position.translate(pushLeft, pushTop);
      if (withPush && !enemy.isCollision(rectAfterPush, this.gameRef)) {
        enemy.translate(pushLeft, pushTop);
      }
    });
  }

  void simpleAttackMeleeByAngle({
    @required FlameAnimation.Animation animationTop,
    @required double damage,
    @required double radAngleDirection,
    int id,
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

    gameRef.addLater(AnimatedObjectOnce(
      animation: animationTop,
      position: positionAttack,
      rotateRadAngle: angle,
    ));

    gameRef
        .visibleEnemies()
        .where((enemy) => enemy.rectCollision.overlaps(positionAttack))
        .forEach((enemy) {
      enemy.receiveDamage(damage, id);
      Rect rectAfterPush = enemy.position.translate(diffBase.dx, diffBase.dy);
      if (withPush && !enemy.isCollision(rectAfterPush, this.gameRef)) {
        enemy.translate(diffBase.dx, diffBase.dy);
      }
    });
  }
}
