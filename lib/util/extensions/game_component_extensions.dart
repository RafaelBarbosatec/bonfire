import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

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
      notObserved?.call();
      return;
    }

    Rect fieldOfVision = Rect.fromCircle(
      center: this.center.toOffset(),
      radius: radiusVision,
    );

    if (fieldOfVision.overlaps(getRectAndCollision(component))) {
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
      notObserved?.call();
      return;
    }

    double visionWidth = radiusVision * 2;
    double visionHeight = radiusVision * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      this.center.x - radiusVision,
      this.center.y - radiusVision,
      visionWidth,
      visionHeight,
    );

    List<T> compObserved = compVisible
        .where((comp) => fieldOfVision.overlaps(comp.toRect()))
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
    TextStyle? config,
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
          center.x,
          y,
        ),
        config: config ??
            TextStyle(
              fontSize: 14,
              color: Color(0xFFFFFFFF),
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
    required Future<SpriteAnimation> animationUp,
    required Vector2 size,
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
    var initPosition = (isObjectCollision()
        ? (this as ObjectCollision).rectCollision
        : this.toRect());

    Vector2 startPosition = initPosition.center.toVector2();

    double displacement = max(initPosition.width, initPosition.height) * 1.2;
    double nextX = displacement * cos(radAngleDirection);
    double nextY = displacement * sin(radAngleDirection);

    Vector2 diffBase = Vector2(nextX, nextY);

    startPosition.add(diffBase);
    startPosition.add(Vector2(-size.x / 2, -size.y / 2));
    gameRef.add(FlyingAttackAngleObject(
      id: id,
      position: startPosition,
      size: size,
      radAngle: radAngleDirection,
      damage: damage,
      speed: speed,
      attackFrom: this is Player ? AttackFromEnum.PLAYER : AttackFromEnum.ENEMY,
      collision: collision,
      withCollision: withCollision,
      onDestroy: onDestroy,
      flyAnimation: animationUp,
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
    required Vector2 size,
    required Direction direction,
    dynamic id,
    double speed = 150,
    double damage = 1,
    bool withCollision = true,
    bool enableDiagonal = true,
    VoidCallback? destroy,
    CollisionConfig? collision,
    LightingConfig? lightingConfig,
    Future<SpriteAnimation>? animationDestroy,
  }) {
    Vector2 startPosition;
    Future<SpriteAnimation> attackRangeAnimation;

    Direction attackDirection = direction;

    Rect rectBase = (this.isObjectCollision())
        ? (this as ObjectCollision).rectCollision
        : toRect();

    switch (attackDirection) {
      case Direction.left:
        attackRangeAnimation = animationLeft;
        startPosition = Vector2(
          rectBase.left - size.x,
          (rectBase.top + (rectBase.height - size.y) / 2),
        );
        break;
      case Direction.right:
        attackRangeAnimation = animationRight;
        startPosition = Vector2(
          rectBase.right,
          (rectBase.top + (rectBase.height - size.y) / 2),
        );
        break;
      case Direction.up:
        attackRangeAnimation = animationUp;
        startPosition = Vector2(
          (rectBase.left + (rectBase.width - size.x) / 2),
          rectBase.top - size.y,
        );
        break;
      case Direction.down:
        attackRangeAnimation = animationDown;
        startPosition = Vector2(
          (rectBase.left + (rectBase.width - size.x) / 2),
          rectBase.bottom,
        );
        break;
      case Direction.upLeft:
        attackRangeAnimation = animationLeft;
        startPosition = Vector2(
          rectBase.left - size.x,
          (rectBase.top + (rectBase.height - size.y) / 2),
        );
        break;
      case Direction.upRight:
        attackRangeAnimation = animationRight;
        startPosition = Vector2(
          rectBase.right,
          (rectBase.top + (rectBase.height - size.y) / 2),
        );
        break;
      case Direction.downLeft:
        attackRangeAnimation = animationLeft;
        startPosition = Vector2(
          rectBase.left - size.x,
          (rectBase.top + (rectBase.height - size.y) / 2),
        );
        break;
      case Direction.downRight:
        attackRangeAnimation = animationRight;
        startPosition = Vector2(
          rectBase.right,
          (rectBase.top + (rectBase.height - size.y) / 2),
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
        size: size,
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
    Future<SpriteAnimation>? animationDown,
    Future<SpriteAnimation>? animationLeft,
    Future<SpriteAnimation>? animationUp,
    dynamic id,
    required double damage,
    required Direction direction,
    required Vector2 size,
    bool withPush = true,
    double? sizePush,
  }) {
    Vector2 positionAttack;
    Future<SpriteAnimation>? anim;
    double pushLeft = 0;
    double pushTop = 0;
    Direction attackDirection = direction;

    Rect rectBase = (this.isObjectCollision())
        ? (this as ObjectCollision).rectCollision
        : toRect();

    switch (attackDirection) {
      case Direction.up:
        positionAttack = Vector2(
          rectBase.center.dx - size.x / 2,
          rectBase.top - size.y,
        );
        if (animationUp != null) anim = animationUp;
        pushTop = (sizePush ?? height) * -1;
        break;
      case Direction.right:
        positionAttack = Vector2(
          rectBase.right,
          rectBase.center.dy - size.y / 2,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? width);
        break;
      case Direction.down:
        positionAttack = Vector2(
          rectBase.center.dx - size.x / 2,
          rectBase.bottom,
        );
        if (animationDown != null) anim = animationDown;
        pushTop = (sizePush ?? height);
        break;
      case Direction.left:
        positionAttack = Vector2(
          rectBase.left - size.x,
          rectBase.center.dy - size.y / 2,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? width) * -1;
        break;
      case Direction.upLeft:
        positionAttack = Vector2(
          rectBase.left - size.x,
          rectBase.center.dy - size.y / 2,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? width) * -1;
        break;
      case Direction.upRight:
        positionAttack = Vector2(
          rectBase.right,
          rectBase.center.dy - size.y / 2,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? width);
        break;
      case Direction.downLeft:
        positionAttack = Vector2(
          rectBase.left - size.x,
          rectBase.center.dy - size.y / 2,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? width) * -1;
        break;
      case Direction.downRight:
        positionAttack = Vector2(
          rectBase.right,
          rectBase.center.dy - size.y / 2,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? width);
        break;
    }

    if (anim != null) {
      gameRef.add(
        AnimatedObjectOnce(
          animation: anim,
          position: positionAttack,
          size: size,
        ),
      );
    }

    gameRef.visibleAttackables().where((a) {
      return (this is Player
              ? a.receivesAttackFromPlayer()
              : a.receivesAttackFromEnemy()) &&
          a.rectAttackable().overlaps(
                Rect.fromLTWH(
                  positionAttack.x,
                  positionAttack.y,
                  size.x,
                  size.y,
                ),
              );
    }).forEach(
      (enemy) {
        enemy.receiveDamage(damage, id);
        final rectAfterPush = enemy.position.translate(pushLeft, pushTop);
        if (withPush &&
            (enemy is ObjectCollision &&
                !(enemy as ObjectCollision)
                    .isCollision(displacement: rectAfterPush)
                    .isNotEmpty)) {
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
    required Vector2 size,
    bool withPush = true,
  }) {
    double angle = radAngleDirection;

    double nextX = height * cos(angle);
    double nextY = width * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Vector2 diffBase = Vector2(
          this.center.x + nextPoint.dx,
          this.center.y + nextPoint.dy,
        ) -
        this.center;

    Rect positionAttack = this.toRect().shift(diffBase.toOffset());

    gameRef.add(
      AnimatedObjectOnce(
        animation: animationTop,
        position: positionAttack.positionVector2,
        size: size,
        rotateRadAngle: angle,
      ),
    );

    gameRef
        .visibleAttackables()
        .where((a) =>
            (this is Player
                ? a.receivesAttackFromPlayer()
                : a.receivesAttackFromEnemy()) &&
            a.rectAttackable().overlaps(positionAttack))
        .forEach((enemy) {
      enemy.receiveDamage(damage, id);
      final rectAfterPush = enemy.position.translate(diffBase.x, diffBase.y);
      if (withPush &&
          (enemy is ObjectCollision &&
              !(enemy as ObjectCollision)
                  .isCollision(displacement: rectAfterPush)
                  .isNotEmpty)) {
        enemy.translate(diffBase.x, diffBase.y);
      }
    });
  }

  Direction getComponentDirectionFromMe(GameComponent? comp) {
    Rect rectToMove = getRectAndCollision(this);
    double centerXPlayer = comp?.center.x ?? 0;
    double centerYPlayer = comp?.center.y ?? 0;

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

  double get top => position.y;
  double get bottom => absolutePositionOfAnchor(Anchor.bottomRight).y;
  double get left => position.x;
  double get right => absolutePositionOfAnchor(Anchor.bottomRight).x;

  bool overlaps(Rect other) {
    if (right <= other.left || other.right <= left) return false;
    if (bottom <= other.top || other.bottom <= top) return false;
    return true;
  }
}
