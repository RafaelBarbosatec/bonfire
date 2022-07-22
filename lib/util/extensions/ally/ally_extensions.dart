import 'dart:ui';

import 'package:bonfire/bonfire.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 24/03/22
extension AllyExtensions on Ally {
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
    Future<SpriteAnimation>? animationDown,
    Future<SpriteAnimation>? animationLeft,
    Future<SpriteAnimation>? animationUp,
    VoidCallback? execute,
  }) {
    if (!this.checkInterval('attackMelee', interval, dtUpdate)) return;

    if (isDead) return;

    Direction direct = direction ?? getComponentDirectionFromMe(gameRef.player);

    this.simpleAttackMeleeByDirection(
      damage: damage,
      direction: direct,
      size: size,
      id: id,
      withPush: withPush,
      sizePush: sizePush,
      animationUp: animationUp,
      animationDown: animationDown,
      animationLeft: animationLeft,
      animationRight: animationRight,
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
    );

    execute?.call();
  }

  /// Execute the ranged attack using a component with animation
  void simpleAttackRange({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    required Future<SpriteAnimation> animationUp,
    required Future<SpriteAnimation> animationDown,
    required Future<SpriteAnimation> animationDestroy,
    required Vector2 size,
    Vector2? destroySize,
    int? id,
    double speed = 150,
    double damage = 1,
    Direction? direction,
    int interval = 1000,
    bool withCollision = true,
    bool enableDiagonal = true,
    CollisionConfig? collision,
    VoidCallback? onDestroy,
    VoidCallback? execute,
    LightingConfig? lightingConfig,
  }) {
    if (!this.checkInterval('attackRange', interval, dtUpdate)) return;

    if (isDead) return;

    Direction direct = direction ?? getComponentDirectionFromMe(gameRef.player);

    this.simpleAttackRangeByDirection(
      animationRight: animationRight,
      animationLeft: animationLeft,
      animationUp: animationUp,
      animationDown: animationDown,
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
      enableDiagonal: enableDiagonal,
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
    );

    if (execute != null) execute();
  }

  /// Checks whether the Enemy is within range. If so, move to it.
  void seeAndMoveToAttackRange({
    required Function(Enemy) positioned,
    VoidCallback? notObserved,
    VoidCallback? observed,
    double radiusVision = 32,
    double? angleVision,
    double? minDistanceFromPlayer,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;

    seeComponentType<Enemy>(
      radiusVision: radiusVision,
      angle: lastDirection.toRadians(),
      angleVision: angleVision,
      observed: (enemy) {
        observed?.call();
        this.positionsItselfAndKeepDistance(
          enemy.first,
          minDistanceFromPlayer: minDistanceFromPlayer,
          radiusVision: radiusVision,
          runOnlyVisibleInScreen: runOnlyVisibleInScreen,
          positioned: (enemy) {
            final playerDirection = this.getComponentDirectionFromMe(enemy);
            lastDirection = playerDirection;
            if (lastDirection == Direction.left ||
                lastDirection == Direction.right) {
              lastDirectionHorizontal = lastDirection;
            }
            idle();
            positioned(enemy as Enemy);
          },
        );
      },
      notObserved: () {
        if (!this.isIdle) {
          this.idle();
        }
        notObserved?.call();
      },
    );
  }
}
