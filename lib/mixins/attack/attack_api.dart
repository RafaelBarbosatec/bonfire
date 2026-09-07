import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

/// API with attack helpers available in every [GameComponent].
///
/// Access it through the `attack` object:
/// ```dart
/// component.attack.melee(damage: 10, size: Vector2(20, 20));
/// component.attack.rangeByAngle(...);
/// ```
class AttackApi {
  final GameComponent comp;

  AttackApi(this.comp);

  /// Executes a melee attack. If [angle] (radians) is provided the attack is
  /// performed in that direction, otherwise [direction] is used (defaults to
  /// the player, the component direction or the last movement direction).
  void melee({
    required double damage,
    required Vector2 size,
    Future<SpriteAnimation>? animation,
    dynamic id,
    Direction? direction,
    double? angle,
    bool withPush = true,
    double? sizePush,
    Vector2? centerOffset,
    double? marginFromCenter,
    bool diagonalEnabled = true,
    AttackOriginEnum? attackFrom,
  }) {
    final origin = attackFrom ?? _defaultAttackFrom();
    if (angle != null) {
      meleeByAngle(
        damage: damage,
        size: size,
        animation: animation,
        id: id,
        angle: angle,
        attackFrom: origin,
        withPush: withPush,
        centerOffset: centerOffset,
        marginFromCenter: marginFromCenter ?? 0,
      );
    } else {
      meleeByDirection(
        damage: damage,
        size: size,
        animationRight: animation,
        id: id,
        direction: direction ?? _defaultMeleeDirection(diagonalEnabled),
        attackFrom: origin,
        withPush: withPush,
        sizePush: sizePush,
        centerOffset: centerOffset,
        marginFromCenter: marginFromCenter,
      );
    }
  }

  /// Executes a ranged attack. If [angle] (radians) or [useAngle] is provided
  /// the projectile is fired in that direction, otherwise [direction] is used
  /// (defaults to the player or the component direction).
  void range({
    required Future<SpriteAnimation> animation,
    required Vector2 size,
    Future<SpriteAnimation>? animationDestroy,
    Vector2? destroySize,
    dynamic id,
    double speed = 150,
    double damage = 1,
    Direction? direction,
    double? angle,
    bool useAngle = false,
    bool withCollision = true,
    bool withDecorationCollision = true,
    ShapeHitbox? collision,
    VoidCallback? onDestroy,
    LightingConfig? lightingConfig,
    Vector2? centerOffset,
    double marginFromOrigin = 16,
    AttackOriginEnum? attackFrom,
  }) {
    final origin = attackFrom ?? _defaultAttackFrom();
    if (angle != null || useAngle) {
      rangeByAngle(
        animation: animation,
        animationDestroy: animationDestroy,
        size: size,
        angle: angle ?? comp.util.getAngleToPlayer(),
        damage: damage,
        attackFrom: origin,
        destroySize: destroySize,
        id: id,
        speed: speed,
        withDecorationCollision: withDecorationCollision,
        onDestroy: onDestroy,
        collision: collision,
        lightingConfig: lightingConfig,
        centerOffset: centerOffset,
        marginFromOrigin: marginFromOrigin,
      );
    } else {
      rangeByDirection(
        animationRight: animation,
        animationDestroy: animationDestroy,
        size: size,
        direction: direction ?? _defaultMeleeDirection(true),
        damage: damage,
        attackFrom: origin,
        destroySize: destroySize,
        id: id,
        speed: speed,
        withCollision: withCollision,
        onDestroy: onDestroy,
        collision: collision,
        lightingConfig: lightingConfig,
        centerOffset: centerOffset,
        marginFromOrigin: marginFromOrigin,
      );
    }
  }

  /// Executes a melee attack by [angle] (radians).
  void meleeByAngle({
    required double damage,
    required double angle,
    required AttackOriginEnum attackFrom,
    required Vector2 size,
    dynamic id,
    Future<SpriteAnimation>? animation,
    bool withPush = true,
    double marginFromCenter = 0,
    Vector2? centerOffset,
    void Function(WithLife attackable)? onDamage,
  }) {
    final initPosition = comp.rectCollision;

    final startPosition =
        initPosition.center.toVector2() + (centerOffset ?? Vector2.zero());

    final displacement =
        max(initPosition.width, initPosition.height) / 2 + marginFromCenter;

    final diffBase = BonfireUtil.diffMovePointByAngle(
      startPosition,
      displacement,
      angle,
    );

    startPosition.add(diffBase);

    if (animation != null) {
      comp.gameRef.add(
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

    comp.gameRef.add(
      DamageHitbox(
        position: startPosition,
        damage: damage,
        origin: attackFrom,
        size: size,
        angle: angle,
        id: id,
        onDamage: (attackable) {
          onDamage?.call(attackable);
          if (withPush && attackable is Movement) {
            _doPush(
              attackable as Movement,
              BonfireUtil.getDirectionFromAngle(angle),
              diffBase,
            );
          }
        },
      ),
    );
  }

  /// Executes a melee attack by [direction].
  void meleeByDirection({
    required double damage,
    required Direction direction,
    required Vector2 size,
    required AttackOriginEnum attackFrom,
    Future<SpriteAnimation>? animationRight,
    dynamic id,
    bool withPush = true,
    double? sizePush,
    double? marginFromCenter,
    Vector2? centerOffset,
    void Function(WithLife attackable)? onDamage,
  }) {
    final rect = comp.rectCollision;
    meleeByAngle(
      angle: direction.toRadians(),
      animation: animationRight,
      attackFrom: attackFrom,
      damage: damage,
      size: size,
      centerOffset: centerOffset,
      marginFromCenter: marginFromCenter ?? max(rect.width, rect.height) / 2,
      id: id,
      withPush: withPush,
      onDamage: onDamage,
    );
  }

  /// Executes a ranged attack using a component with animation by [angle].
  void rangeByAngle({
    /// use animation facing right.
    required Future<SpriteAnimation> animation,
    required Vector2 size,

    /// Use radians angle
    required double angle,
    required double damage,
    required AttackOriginEnum attackFrom,
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
    final initPosition = comp.rectCollision;

    var startPosition =
        initPosition.center.toVector2() + (centerOffset ?? Vector2.zero());

    final displacement =
        max(initPosition.width, initPosition.height) / 2 + marginFromOrigin;

    startPosition = BonfireUtil.movePointByAngle(
      startPosition,
      displacement,
      angle,
    );

    comp.gameRef.add(
      FlyingAttackGameObject.byAngle(
        id: id,
        position: startPosition,
        size: size,
        angle: angle,
        damage: damage,
        speed: speed,
        attackFrom: attackFrom,
        shapeCollision: collision,
        withDecorationCollision: withDecorationCollision,
        onDestroy: onDestroy,
        destroySize: destroySize,
        animation: animation,
        animationDestroy: animationDestroy,
        lightingConfig: lightingConfig,
      ),
    );
  }

  /// Executes a ranged attack using a component with animation by [direction].
  void rangeByDirection({
    required Future<SpriteAnimation> animationRight,
    required Vector2 size,
    required Direction direction,
    required AttackOriginEnum attackFrom,
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
    final initPosition = comp.rectCollision;

    var startPosition =
        initPosition.center.toVector2() + (centerOffset ?? Vector2.zero());

    final displacement =
        max(initPosition.width, initPosition.height) / 2 + marginFromOrigin;

    startPosition = BonfireUtil.movePointByAngle(
      startPosition,
      displacement,
      direction.toRadians(),
    );
    comp.gameRef.add(
      FlyingAttackGameObject.byDirection(
        direction: direction,
        animation: animationRight,
        attackFrom: attackFrom,
        damage: damage,
        size: size,
        animationDestroy: animationDestroy,
        destroySize: destroySize,
        id: id,
        lightingConfig: lightingConfig,
        onDestroy: onDestroy,
        speed: speed,
        withDecorationCollision: withCollision,
        position: startPosition,
      ),
    );
  }

  AttackOriginEnum _defaultAttackFrom() {
    return comp is Enemy
        ? AttackOriginEnum.ENEMY
        : AttackOriginEnum.PLAYER_OR_ALLY;
  }

  Direction _defaultMeleeDirection(bool diagonalEnabled) {
    if (comp is Enemy) {
      final player = comp.gameRef.player;
      return player != null
          ? comp.util.getDirectionToTarget(player)
          : Direction.right;
    }
    if (comp is Player) {
      final d = (comp as Movement).direction;
      if (diagonalEnabled) {
        return d;
      }
      switch (d) {
        case Direction.upLeft:
        case Direction.downLeft:
          return Direction.left;
        case Direction.upRight:
        case Direction.downRight:
          return Direction.right;
        case Direction.up:
        case Direction.down:
        case Direction.left:
        case Direction.right:
          return d;
      }
    }
    return comp is Movement ? (comp as Movement).direction : Direction.right;
  }

  void _doPush(
    Movement comp,
    Direction directionFromAngle,
    Vector2 displacement,
  ) {
    if (comp.canMove(
      directionFromAngle,
      displacement: displacement.maxValue(),
    )) {
      comp.position = comp.position + displacement;
    }
  }
}
