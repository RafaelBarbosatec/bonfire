import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/mixins/attackable.dart';
import 'package:bonfire/npc/enemy/rotation_enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

extension RotationEnemyExtensions on RotationEnemy {
  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToPlayer({
    required Function(Player) closePlayer,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;
    if (runOnlyVisibleInScreen && !isVisible) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        double radAngle = getAngleFromPlayer();

        Rect playerRect = player is ObjectCollision
            ? (player as ObjectCollision).rectCollision
            : player.toRect();
        Rect rectPlayerCollision = Rect.fromLTWH(
          playerRect.left - margin,
          playerRect.top - margin,
          playerRect.width + (margin * 2),
          playerRect.height + (margin * 2),
        );

        if (rectConsideringCollision.overlaps(rectPlayerCollision)) {
          closePlayer(player);
          idle();
          moveFromAngleDodgeObstacles(0, radAngle);
          return;
        }

        bool onMove = moveFromAngleDodgeObstacles(speed, radAngle);
        if (!onMove) {
          idle();
        }
      },
      notObserved: () {
        idle();
        notObserved?.call();
      },
    );
  }

  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToAttackRange({
    required Function(Player) positioned,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double? minDistanceCellsFromPlayer,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;
    if (runOnlyVisibleInScreen && !isVisible) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        positioned(player);

        Rect playerRect = player is ObjectCollision
            ? (player as ObjectCollision).rectCollision
            : player.toRect();
        double distance = (minDistanceCellsFromPlayer ?? radiusVision);
        double radAngle = getAngleFromPlayer();

        Vector2 myPosition = Vector2(
          center.x,
          center.y,
        );

        Vector2 playerPosition = Vector2(
          playerRect.center.dx,
          playerRect.center.dy,
        );

        double dist = myPosition.distanceTo(playerPosition);

        if (dist >= distance) {
          moveFromAngleDodgeObstacles(0, radAngle);
          idle();
          return;
        }

        bool onMove = moveFromAngleDodgeObstacles(
          speed,
          getInverseAngleFromPlayer(),
        );

        if (!onMove) {
          idle();
        }
      },
      notObserved: () {
        idle();
        notObserved?.call();
      },
    );
  }

  ///Execute simple attack melee using animation
  void simpleAttackMelee({
    required Future<SpriteAnimation> animationRight,
    required double damage,
    required Vector2 size,
    int? id,
    bool withPush = true,
    double? radAngleDirection,
    VoidCallback? execute,
    int interval = 1000,
    double marginFromOrigin = 16,
    Vector2? centerOffset,
  }) {
    if (!checkInterval('attackMelee', interval, dtUpdate)) return;

    if (isDead) return;

    simpleAttackMeleeByAngle(
      id: id,
      withPush: withPush,
      centerOffset: centerOffset,
      marginFromOrigin: marginFromOrigin,
      damage: damage,
      size: size,
      angle: angle,
      animation: animationRight,
      attackFrom: AttackFromEnum.ENEMY,
    );

    execute?.call();
  }

  /// Execute the ranged attack using a component with animation
  void simpleAttackRange({
    /// use animation facing right.
    required Future<SpriteAnimation> animation,
    required Future<SpriteAnimation> animationDestroy,
    required Vector2 size,
    Vector2? destroySize,
    double? radAngleDirection,
    int? id,
    double speed = 150,
    double damage = 1,
    int interval = 1000,
    bool withDecorationCollision = true,
    VoidCallback? onDestroy,
    CollisionConfig? collision,
    VoidCallback? onExecute,
    LightingConfig? lightingConfig,
    Vector2? centerOffset,
    double marginFromOrigin = 16,
  }) {
    if (!checkInterval('attackRange', interval, dtUpdate)) return;

    if (isDead) return;

    simpleAttackRangeByAngle(
      animation: animation,
      animationDestroy: animationDestroy,
      size: size,
      angle: radAngleDirection ?? angle,
      id: id,
      speed: speed,
      damage: damage,
      withDecorationCollision: withDecorationCollision,
      onDestroy: onDestroy,
      destroySize: destroySize,
      collision: collision,
      lightingConfig: lightingConfig,
      centerOffset: centerOffset,
      marginFromOrigin: marginFromOrigin,
      attackFrom: AttackFromEnum.ENEMY,
    );

    onExecute?.call();
  }
}
