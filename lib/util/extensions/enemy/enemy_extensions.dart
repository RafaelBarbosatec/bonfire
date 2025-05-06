import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

/// Functions util to use in your [Enemy]
extension EnemyExtensions on Enemy {
  ///Execute simple attack melee using animation
  void simpleAttackMelee({
    required double damage,
    required Vector2 size,
    int? id,
    int interval = 1000,
    bool withPush = false,
    double? sizePush,
    Direction? direction,
    Future<SpriteAnimation>? animationRight,
    VoidCallback? execute,
    Vector2? centerOffset,
  }) {
    if (!checkInterval('attackMelee', interval, lastDt) || isDead) {
      return;
    }

    final direct = direction ??
        (gameRef.player != null
            ? getDirectionToTarget(gameRef.player!)
            : lastDirection);

    simpleAttackMeleeByDirection(
      damage: damage,
      direction: direct,
      size: size,
      id: id,
      withPush: withPush,
      sizePush: sizePush,
      animationRight: animationRight,
      attackFrom: AttackOriginEnum.ENEMY,
      centerOffset: centerOffset,
    );

    execute?.call();
  }

  /// Execute the ranged attack using a component with animation
  void simpleAttackRange({
    required Future<SpriteAnimation> animation,
    required Future<SpriteAnimation> animationDestroy,
    required Vector2 size,
    Vector2? destroySize,
    int? id,
    double speed = 150,
    double damage = 1,
    int interval = 1000,
    bool withCollision = true,
    bool useAngle = false,
    ShapeHitbox? collision,
    VoidCallback? onDestroy,
    VoidCallback? execute,
    LightingConfig? lightingConfig,
  }) {
    if (!checkInterval('attackRange', interval, lastDt) || isDead) {
      return;
    }

    if (useAngle) {
      simpleAttackRangeByAngle(
        animation: animation,
        animationDestroy: animationDestroy,
        size: size,
        angle: getAngleToPlayer(),
        id: id,
        speed: speed,
        damage: damage,
        withDecorationCollision: withCollision,
        collision: collision,
        onDestroy: onDestroy,
        destroySize: destroySize,
        lightingConfig: lightingConfig,
        attackFrom: AttackOriginEnum.ENEMY,
      );
    } else {
      final direct = gameRef.player != null
          ? getDirectionToTarget(gameRef.player!)
          : lastDirection;
      simpleAttackRangeByDirection(
        animationRight: animation,
        animationDestroy: animationDestroy,
        size: size,
        direction: direct,
        id: id,
        speed: speed,
        damage: damage,
        withCollision: withCollision,
        collision: collision,
        onDestroy: onDestroy,
        destroySize: destroySize,
        lightingConfig: lightingConfig,
        attackFrom: AttackOriginEnum.ENEMY,
      );
    }

    execute?.call();
  }

  /// Checks whether the player is within range. If so, move to it.
  /// [visionAngle] in radians
  /// [angle] in radians. is automatically picked up using the component's direction.
  void seeAndMoveToAttackRange({
    Function(Player)? positioned,
    // return true to stop move.
    BoolCallback? notObserved,
    Function(Player)? observed,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double? minDistanceFromPlayer,
    bool useDiagonal = true,
    // bool useDiagonal = true,
  }) {
    if (minDistanceFromPlayer != null) {
      assert(minDistanceFromPlayer < radiusVision);
    }

    if (isDead) {
      return;
    }

    seePlayer(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle,
      observed: (player) {
        observed?.call(player);
        final minD = minDistanceFromPlayer ?? (radiusVision - 5);
        if (useDiagonal) {
          final inDistance = keepDistance(
            player,
            minD,
          );
          if (inDistance) {
            final playerDirection = getDirectionToTarget(player);
            lastDirection = playerDirection;
            if (lastDirection == Direction.left ||
                lastDirection == Direction.right) {
              lastDirectionHorizontal = lastDirection;
            }

            if (checkInterval('seeAndMoveToAttackRange', 500, lastDt)) {
              stopMove();
            }
            positioned?.call(player);
          }
        } else {
          positionsItselfAndKeepDistance(
            player,
            minDistanceFromPlayer: minD,
            radiusVision: radiusVision,
            positioned: (player) {
              final playerDirection = getDirectionToTarget(player);
              lastDirection = playerDirection;
              if (lastDirection == Direction.left ||
                  lastDirection == Direction.right) {
                lastDirectionHorizontal = lastDirection;
              }

              if (checkInterval('seeAndMoveToAttackRange', 500, lastDt)) {
                stopMove();
              }
              positioned?.call(player);
            },
          );
        }
      },
      notObserved: () {
        final stop = notObserved?.call() ?? true;
        if (stop) {
          stopMove(forceIdle: true);
        }
      },
    );
  }
}
