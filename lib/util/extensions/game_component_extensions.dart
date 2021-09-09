import 'dart:math';
import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

extension GameComponentExtensions on GameComponent {
  /// This method we notify when detect the component when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  void seeComponent(
    GameComponent component, {
    required Function(GameComponent) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    if (component.shouldRemove) {
      if (notObserved != null) notObserved();
      return;
    }

    double vision = radiusVision * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      this.position.center.dx - radiusVision,
      this.position.center.dy - radiusVision,
      vision,
      vision,
    );

    if (fieldOfVision.overlaps(getRectAndCollision(component).rect)) {
      observed(component);
    } else {
      notObserved?.call();
    }
  }

  /// This method we notify when detect components by type when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  void seeComponentType<T extends GameComponent>({
    required Function(List<T>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    var compVisible = this.gameRef.visibleComponents().where((element) {
      return element is T && element != this;
    }).cast<T>();

    if (compVisible.isEmpty) {
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

    List<T> compObserved = compVisible
        .where((comp) => fieldOfVision.overlaps(comp.position.rect))
        .toList();

    if (compObserved.isNotEmpty) {
      observed(compObserved);
    } else {
      notObserved?.call();
    }
  }

  /// Add in the game a text with animation representing damage received
  void showDamage(
    double damage, {
    TextPaintConfig? config,
    double initVelocityTop = -5,
    double gravity = 0.5,
    double maxDownSize = 20,
    DirectionTextDamage direction = DirectionTextDamage.RANDOM,
    bool onlyUp = false,
  }) {
    gameRef.add(
      TextDamageComponent(
        damage.toInt().toString(),
        Vector2(
          position.center.dx,
          position.top,
        ),
        config: config ??
            TextPaintConfig(
              fontSize: 14,
              color: Colors.white,
            ),
        initVelocityTop: initVelocityTop,
        gravity: gravity,
        direction: direction,
        onlyUp: onlyUp,
        maxDownSize: maxDownSize,
      ),
    );
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
    VoidCallback? onDestroy,
    CollisionConfig? collision,
    LightingConfig? lightingConfig,
  }) {
    double angle = radAngleDirection;
    double nextX = this.width * cos(angle);
    double nextY = this.height * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(
          this.position.center.dx + nextPoint.dx,
          this.position.center.dy + nextPoint.dy,
        ) -
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
      attackFrom: this is Player ? AttackFromEnum.PLAYER : AttackFromEnum.ENEMY,
      collision: collision,
      withCollision: withCollision,
      onDestroy: onDestroy,
      flyAnimation: animationTop,
      destroyAnimation: animationDestroy,
      lightingConfig: lightingConfig,
    ));
  }

  /// Execute the ranged attack using a component with animation
  void simpleAttackRangeByDirection({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    required Future<SpriteAnimation> animationUp,
    required Future<SpriteAnimation> animationDown,
    Future<SpriteAnimation>? animationDestroy,
    required double width,
    required double height,
    required Direction direction,
    dynamic id,
    double speed = 150,
    double damage = 1,
    bool withCollision = true,
    bool enableDiagonal = true,
    VoidCallback? destroy,
    CollisionConfig? collision,
    LightingConfig? lightingConfig,
  }) {
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
        attackRangeAnimation = animationUp;
        startPosition = Vector2(
          (rectBase.rect.left + (rectBase.rect.width - width) / 2),
          rectBase.rect.top - height,
        );
        break;
      case Direction.down:
        attackRangeAnimation = animationDown;
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
        enableDiagonal: enableDiagonal,
        attackFrom:
            this is Player ? AttackFromEnum.PLAYER : AttackFromEnum.ENEMY,
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
      return (this is Player
              ? a.receivesAttackFromPlayer()
              : a.receivesAttackFromEnemy()) &&
          a.rectAttackable().rect.overlaps(positionAttack);
    }).forEach(
      (enemy) {
        enemy.receiveDamage(damage, id);
        final rectAfterPush =
            enemy.position.position.translate(pushLeft, pushTop);
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
            (this is Player
                ? a.receivesAttackFromPlayer()
                : a.receivesAttackFromEnemy()) &&
            a.rectAttackable().overlaps(positionAttack))
        .forEach((enemy) {
      enemy.receiveDamage(damage, id);
      final rectAfterPush =
          enemy.position.position.translate(diffBase.dx, diffBase.dy);
      if (withPush &&
          (enemy is ObjectCollision &&
              !(enemy as ObjectCollision)
                  .isCollision(displacement: rectAfterPush))) {
        enemy.translate(diffBase.dx, diffBase.dy);
      }
    });
  }

  Direction getComponentDirectionFromMe(GameComponent? comp) {
    Vector2Rect rectToMove = getRectAndCollision(this);
    double centerXPlayer = comp?.position.center.dx ?? 0;
    double centerYPlayer = comp?.position.center.dy ?? 0;

    double centerYEnemy = rectToMove.center.dy;
    double centerXEnemy = rectToMove.center.dx;

    double diffX = centerXEnemy - centerXPlayer;
    double diffY = centerYEnemy - centerYPlayer;

    if (diffX.abs() > diffY.abs()) {
      return diffX > 0 ? Direction.left : Direction.right;
    } else {
      return diffY > 0 ? Direction.up : Direction.down;
    }
  }
}
