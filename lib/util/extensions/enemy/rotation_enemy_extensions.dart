import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/mixins/attackable.dart';
import 'package:bonfire/npc/enemy/rotation_enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

extension RotationEnemyExtensions on RotationEnemy {
  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToPlayer({
    required Function(Player) closePlayer,
    // return true to stop move.
    BoolCallback? notObserved,
    double radiusVision = 32,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if ((runOnlyVisibleInScreen && !isVisible) || isDead) {
      return;
    }

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        final radAngle = getAngleToPlayer();

        final playerRect = player.rectCollision;
        final rectPlayerCollision = playerRect.inflate(margin);

        if (rectCollision.overlaps(rectPlayerCollision)) {
          closePlayer(player);
          moveFromAngle(radAngle);
          stopMove();
          return;
        }

        moveFromAngle(radAngle);
      },
      notObserved: () {
        final stop = notObserved?.call() ?? true;
        if (stop) {
          stopMove();
        }
      },
    );
  }

  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToAttackRange({
    required Function(Player) positioned,
    // return true to stop move.
    BoolCallback? notObserved,
    double radiusVision = 32,
    double? minDistanceCellsFromPlayer,
    bool runOnlyVisibleInScreen = true,
  }) {
    if ((runOnlyVisibleInScreen && !isVisible) || isDead) {
      return;
    }

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        positioned(player);

        final playerRect = player.rectCollision;
        final distance = minDistanceCellsFromPlayer ?? radiusVision;

        final myPosition = Vector2(
          center.x,
          center.y,
        );

        final playerPosition = Vector2(
          playerRect.center.dx,
          playerRect.center.dy,
        );

        final dist = myPosition.distanceTo(playerPosition);

        if (dist >= distance) {
          stopMove();
          return;
        }

        moveFromAngle(
          getInverseAngleToPlayer(),
        );
      },
      notObserved: () {
        final stop = notObserved?.call() ?? true;
        if (stop) {
          stopMove();
        }
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
    double marginFromCenter = 16,
    Vector2? centerOffset,
  }) {
    if (!checkInterval('attackMelee', interval, lastDt) || isDead) {
      return;
    }

    simpleAttackMeleeByAngle(
      id: id,
      withPush: withPush,
      centerOffset: centerOffset,
      marginFromCenter: marginFromCenter,
      damage: damage,
      size: size,
      angle: angle,
      animation: animationRight,
      attackFrom: AttackOriginEnum.ENEMY,
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
    ShapeHitbox? collision,
    VoidCallback? onExecute,
    LightingConfig? lightingConfig,
    Vector2? centerOffset,
    double marginFromOrigin = 16,
  }) {
    if (!checkInterval('attackRange', interval, lastDt) || isDead) {
      return;
    }

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
      attackFrom: AttackOriginEnum.ENEMY,
    );

    onExecute?.call();
  }
}
