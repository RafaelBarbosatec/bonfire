import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/mixins/attackable.dart';
import 'package:bonfire/npc/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/extensions/game_component_extensions.dart';
import 'package:bonfire/util/extensions/movement_extensions.dart';
import 'package:bonfire/util/extensions/npc/npc_extensions.dart';
import 'package:flame/components.dart';
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
    if (!checkInterval('attackMelee', interval, dtUpdate)) return;

    if (isDead) return;

    Direction direct = direction ?? getComponentDirectionFromMe(gameRef.player);

    simpleAttackMeleeByDirection(
      damage: damage,
      direction: direct,
      size: size,
      id: id,
      withPush: withPush,
      sizePush: sizePush,
      animationRight: animationRight,
      attackFrom: AttackFromEnum.ENEMY,
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
    bool enableDiagonal = true,
    CollisionConfig? collision,
    VoidCallback? onDestroy,
    VoidCallback? execute,
    LightingConfig? lightingConfig,
  }) {
    if (!checkInterval('attackRange', interval, dtUpdate)) return;

    if (isDead) return;

    Direction direct = direction ?? getComponentDirectionFromMe(gameRef.player);

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
      enableDiagonal: enableDiagonal,
      attackFrom: AttackFromEnum.ENEMY,
    );

    if (execute != null) execute();
  }

  /// Checks whether the player is within range. If so, move to it.
  /// [visionAngle] in radians
  /// [angle] in radians. is automatically picked up using the component's direction.
  void seeAndMoveToAttackRange({
    required Function(Player) positioned,
    VoidCallback? notObserved,
    VoidCallback? observed,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double? minDistanceFromPlayer,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;

    seePlayer(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle,
      observed: (player) {
        observed?.call();
        positionsItselfAndKeepDistance(
          player,
          minDistanceFromPlayer: minDistanceFromPlayer,
          radiusVision: radiusVision,
          runOnlyVisibleInScreen: runOnlyVisibleInScreen,
          positioned: (player) {
            final playerDirection = getComponentDirectionFromMe(player);
            lastDirection = playerDirection;
            if (lastDirection == Direction.left ||
                lastDirection == Direction.right) {
              lastDirectionHorizontal = lastDirection;
            }
            idle();
            positioned(player as Player);
          },
        );
      },
      notObserved: () {
        if (!isIdle) {
          idle();
        }
        notObserved?.call();
      },
    );
  }
}
