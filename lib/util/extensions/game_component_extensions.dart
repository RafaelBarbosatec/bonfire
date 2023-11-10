import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

extension GameComponentExtensions on GameComponent {
  /// Add in the game a text with animation representing damage received
  void showDamage(
    double damage, {
    TextStyle? config,
    double initVelocityUp = -5,
    double gravity = 0.5,
    double maxDownSize = 20,
    DirectionTextDamage direction = DirectionTextDamage.RANDOM,
    bool onlyUp = false,
  }) {
    if (!hasGameRef) return;
    gameRef.add(
      TextDamageComponent(
        damage.toInt().toString(),
        Vector2(rectCollision.center.dx, rectCollision.top),
        config: config ??
            const TextStyle(
              fontSize: 14,
              color: Color(0xFFFFFFFF),
            ),
        initVelocityUp: initVelocityUp,
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
    ShapeHitbox? collision,
    LightingConfig? lightingConfig,
    double marginFromOrigin = 16,
    Vector2? centerOffset,
  }) {
    var initPosition = rectCollision;

    Vector2 startPosition =
        initPosition.center.toVector2() + (centerOffset ?? Vector2.zero());

    double displacement =
        max(initPosition.width, initPosition.height) / 2 + marginFromOrigin;

    startPosition = BonfireUtil.movePointByAngle(
      startPosition,
      displacement,
      angle,
    );

    gameRef.add(
      FlyingAttackGameObject.byAngle(
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
        animation: animation,
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
    VoidCallback? onDestroy,
    ShapeHitbox? collision,
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
    double? marginFromCenter,
    Vector2? centerOffset,
  }) {
    final rect = rectCollision;

    simpleAttackMeleeByAngle(
      angle: direction.toRadians(),
      animation: animationRight,
      attackFrom: attackFrom,
      damage: damage,
      size: size,
      centerOffset: centerOffset,
      marginFromCenter: marginFromCenter ?? max(rect.width, rect.height) / 2,
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
    double marginFromCenter = 0,
    Vector2? centerOffset,
  }) {
    var initPosition = rectCollision;

    Vector2 startPosition =
        initPosition.center.toVector2() + (centerOffset ?? Vector2.zero());

    double displacement = max(
              initPosition.width,
              initPosition.height,
            ) /
            2 +
        marginFromCenter;

    Vector2 diffBase = BonfireUtil.diffMovePointByAngle(
      startPosition,
      displacement,
      angle,
    );

    startPosition.add(diffBase);

    if (animation != null) {
      gameRef.add(
        AnimatedGameObject(
          animation: animation,
          position: startPosition,
          size: size,
          angle: angle,
          anchor: Anchor.center,
          loop: false,
          renderAboveComponents: true,
        ),
      );
    }

    Rect positionAttack = Rect.fromCenter(
      center: startPosition.toOffset(),
      width: size.x,
      height: size.y,
    );

    gameRef
        .attackables(onlyVisible: true)
        .where((a) => a.rectAttackable().overlaps(positionAttack) && a != this)
        .forEach((enemy) {
      enemy.receiveDamage(attackFrom, damage, id);
      if (withPush && enemy is Movement) {
        (enemy as Movement).translate(diffBase);
      }
    });
  }

  Direction getComponentDirectionFromMe(GameComponent comp) {
    return BonfireUtil.getDirectionFromAngle(
      getAngleFromTarget(comp),
    );
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
    Curve? reverseCurve,
    bool autoStart = true,
    bool infinite = false,
    VoidCallback? onFinish,
    ValueChanged<double>? onChange,
  }) {
    final valueGenerator = ValueGeneratorComponent(
      duration,
      end: end,
      begin: begin,
      curve: curve,
      reverseCurve: reverseCurve,
      onFinish: onFinish,
      onChange: onChange,
      autoStart: autoStart,
      infinite: infinite,
    );
    add(valueGenerator);
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
    ComponentKey? key,
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
        key: key,
      ),
    );
  }

  /// Get angle between this comp to target
  double getAngleFromTarget(GameComponent target) {
    return BonfireUtil.angleBetweenPointsOffset(
      rectCollision.center,
      target.rectCollision.center,
    );
  }
}
