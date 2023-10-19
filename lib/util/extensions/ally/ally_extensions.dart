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
    VoidCallback? execute,
    Vector2? centerOffset,
  }) {
    if (!checkInterval('attackMelee', interval, dtUpdate)) return;

    if (isDead) return;

    Direction direct = direction ?? lastDirection;

    simpleAttackMeleeByDirection(
      damage: damage,
      direction: direct,
      size: size,
      id: id,
      withPush: withPush,
      sizePush: sizePush,
      animationRight: animationRight,
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
      centerOffset: centerOffset,
    );

    execute?.call();
  }

  /// Execute the ranged attack using a component with animation
  void simpleAttackRange({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationDestroy,
    required Vector2 size,
    Vector2? destroySize,
    int? id,
    double speed = 150,
    double damage = 1,
    Direction? direction,
    int interval = 1000,
    bool withCollision = true,
    ShapeHitbox? collision,
    VoidCallback? onDestroy,
    VoidCallback? execute,
    LightingConfig? lightingConfig,
  }) {
    if (!checkInterval('attackRange', interval, dtUpdate)) return;

    if (isDead) return;

    Direction direct = direction ?? lastDirection;

    simpleAttackRangeByDirection(
      animationRight: animationRight,
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
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
    );

    if (execute != null) execute();
  }

  /// Checks whether the Enemy is within range. If so, move to it.
  /// [visionAngle] in radians
  /// [angle] in radians. is automatically picked up using the component's direction.
  void seeAndMoveToAttackRange({
    Function(Enemy)? positioned,
    // return true to stop move.
    BoolCallback? notObserved,
    Function(Enemy)? observed,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double? minDistanceFromPlayer,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;

    seeComponentType<Enemy>(
      radiusVision: radiusVision,
      angle: angle ?? lastDirection.toRadians(),
      visionAngle: visionAngle,
      observed: (enemy) {
        var e = enemy.first;
        observed?.call(e);
        bool inDistance = keepDistance(
          e,
          (minDistanceFromPlayer ?? (radiusVision - 5)),
        );
        if (inDistance) {
          final playerDirection = getComponentDirectionFromMe(e);
          lastDirection = playerDirection;
          if (lastDirection == Direction.left ||
              lastDirection == Direction.right) {
            lastDirectionHorizontal = lastDirection;
          }

          if (checkInterval('seeAndMoveToAttackRange', 500, dtUpdate)) {
            stopMove();
          }
          positioned?.call(e);
        }
      },
      notObserved: () {
        bool stop = notObserved?.call() ?? true;
        if (stop) {
          stopMove();
        }
      },
    );
  }
}
