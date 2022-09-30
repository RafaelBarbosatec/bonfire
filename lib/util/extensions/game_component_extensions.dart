import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

extension GameComponentExtensions on GameComponent {
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
    if (!hasGameRef) return;
    gameRef.add(
      TextDamageComponent(
        damage.toInt().toString(),
        Vector2(
          center.x,
          y,
        ),
        config: config ??
            const TextStyle(
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
    /// use animation facing right.
    required Future<SpriteAnimation> animation,
    required Vector2 size,

    /// Use radians angle
    required double angle,
    required double damage,
    required AttackFromEnum attackFrom,
    Vector2? destroySize,
    Future<SpriteAnimation>? animationDestroy,
    dynamic id,
    double speed = 150,
    bool withDecorationCollision = true,
    VoidCallback? onDestroy,
    CollisionConfig? collision,
    LightingConfig? lightingConfig,
    double marginFromOrigin = 16,
    Vector2? centerOffset,
  }) {
    var initPosition = rectConsideringCollision;

    Vector2 startPosition =
        initPosition.center.toVector2() + (centerOffset ?? Vector2.zero());

    double displacement =
        max(initPosition.width, initPosition.height) / 2 + marginFromOrigin;

    startPosition = BonfireUtil.movePointByAngle(
      startPosition,
      displacement,
      angle,
    );

    startPosition.add(Vector2(-size.x / 2, -size.y / 2));
    gameRef.add(
      FlyingAttackObject.byAngle(
        id: id,
        position: startPosition,
        size: size,
        angle: angle,
        damage: damage,
        speed: speed,
        attackFrom: attackFrom,
        collision: collision,
        withDecorationCollision: withDecorationCollision,
        onDestroy: onDestroy,
        destroySize: destroySize,
        flyAnimation: animation,
        animationDestroy: animationDestroy,
        lightingConfig: lightingConfig,
      ),
    );
  }

  /// Execute the ranged attack using a component with animation
  void simpleAttackRangeByDirection({
    required Future<SpriteAnimation> animationRight,
    required Vector2 size,
    required Direction direction,
    required AttackFromEnum attackFrom,
    Vector2? destroySize,
    dynamic id,
    double speed = 150,
    double damage = 1,
    bool withCollision = true,
    bool enableDiagonal = true,
    VoidCallback? onDestroy,
    CollisionConfig? collision,
    LightingConfig? lightingConfig,
    Future<SpriteAnimation>? animationDestroy,
    double marginFromOrigin = 16,
    Vector2? centerOffset,
  }) {
    simpleAttackRangeByAngle(
      angle: direction.toRadians(),
      animation: animationRight,
      attackFrom: attackFrom,
      damage: damage,
      size: size,
      animationDestroy: animationDestroy,
      centerOffset: centerOffset,
      marginFromOrigin: marginFromOrigin,
      collision: collision,
      destroySize: destroySize,
      id: id,
      lightingConfig: lightingConfig,
      onDestroy: onDestroy,
      speed: speed,
      withDecorationCollision: withCollision,
    );
  }

  ///Execute simple attack melee using animation
  void simpleAttackMeleeByDirection({
    Future<SpriteAnimation>? animationRight,
    dynamic id,
    required double damage,
    required Direction direction,
    required Vector2 size,
    required AttackFromEnum attackFrom,
    bool withPush = true,
    double? sizePush,
    Vector2? centerOffset,
  }) {
    final rect = rectConsideringCollision;

    simpleAttackMeleeByAngle(
      angle: direction.toRadians(),
      animation: animationRight,
      attackFrom: attackFrom,
      damage: damage,
      size: size,
      centerOffset: centerOffset,
      marginFromOrigin: max(rect.width + 2, rect.height + 2),
      id: id,
      withPush: withPush,
    );
  }

  ///Execute simple attack melee using animation
  void simpleAttackMeleeByAngle({
    dynamic id,

    /// use animation facing right.
    Future<SpriteAnimation>? animation,
    required double damage,

    /// Use radians angle
    required double angle,
    required AttackFromEnum attackFrom,
    required Vector2 size,
    bool withPush = true,
    double marginFromOrigin = 16,
    Vector2? centerOffset,
  }) {
    var initPosition = rectConsideringCollision;

    Vector2 startPosition =
        initPosition.center.toVector2() + (centerOffset ?? Vector2.zero());

    double displacement =
        max(initPosition.width, initPosition.height) / 2 + marginFromOrigin;

    Vector2 diffBase = BonfireUtil.diffMovePointByAngle(
      startPosition,
      displacement,
      angle,
    );

    startPosition.add(diffBase);
    startPosition.add(Vector2(-size.x / 2, -size.y / 2));

    if (animation != null) {
      gameRef.add(
        AnimatedObjectOnce(
          animation: animation,
          position: startPosition,
          size: size,
          rotateRadAngle: angle,
        ),
      );
    }

    Rect positionAttack = Rect.fromLTWH(
      startPosition.x,
      startPosition.y,
      size.x,
      size.y,
    );

    gameRef
        .visibleAttackables()
        .where((a) => a.rectAttackable().overlaps(positionAttack) && a != this)
        .forEach((enemy) {
      enemy.receiveDamage(attackFrom, damage, id);
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
    Rect rectToMove = rectConsideringCollision;
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

  /// Gets rect used how base in calculations considering collision
  Rect get rectConsideringCollision {
    return (isObjectCollision()
        ? (this as ObjectCollision).rectCollision
        : toRect());
  }

  /// Method that checks if this component contain collisions
  bool isObjectCollision() {
    return (this is ObjectCollision &&
        (this as ObjectCollision).containCollision());
  }

  Direction? directionThePlayerIsIn() {
    Player? player = gameRef.player;
    if (player == null) return null;
    var diffX = center.x - player.center.x;
    var diffPositiveX = diffX < 0 ? diffX *= -1 : diffX;
    var diffY = center.y - player.center.y;
    var diffPositiveY = diffY < 0 ? diffY *= -1 : diffY;

    if (diffPositiveX > diffPositiveY) {
      if (player.center.x > center.x) {
        return Direction.right;
      } else if (player.center.x < center.x) {
        return Direction.left;
      }
    } else {
      if (player.center.y > center.y) {
        return Direction.down;
      } else if (player.center.y < center.y) {
        return Direction.up;
      }
    }

    return null;
  }

  /// Used to generate numbers to create your animations or anythings
  ValueGeneratorComponent generateValues(
    Duration duration, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.linear,
    bool autoStart = true,
    VoidCallback? onFinish,
    ValueChanged<double>? onChange,
  }) {
    final valueGenerator = ValueGeneratorComponent(duration,
        end: end,
        begin: begin,
        curve: curve,
        onFinish: onFinish,
        onChange: onChange,
        autoStart: autoStart);
    gameRef.add(valueGenerator);
    return valueGenerator;
  }

  /// Used to add particles in your component.
  void addParticle(
    Particle particle, {
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) {
    add(
      ParticleSystemComponent(
        particle: particle,
        position: position,
        size: size,
        scale: scale,
        angle: angle,
        anchor: anchor,
        priority: priority,
      ),
    );
  }
}
