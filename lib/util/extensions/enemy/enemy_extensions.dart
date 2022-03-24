import 'dart:math';

import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/npc/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/extensions/game_component_extensions.dart';
import 'package:bonfire/util/extensions/movement_extensions.dart';
import 'package:bonfire/util/extensions/npc/npc_extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import '../../mixins/attackable.dart';

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
      attacker: AttackFromEnum.ENEMY,
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
    );

    if (execute != null) execute();
  }

  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToAttackRange({
    required Function(Player) positioned,
    VoidCallback? notObserved,
    VoidCallback? observed,
    double radiusVision = 32,
    double? minDistanceFromPlayer,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        observed?.call();
        this.positionsItselfAndKeepDistance(
          player,
          minDistanceFromPlayer: minDistanceFromPlayer,
          radiusVision: radiusVision,
          runOnlyVisibleInScreen: runOnlyVisibleInScreen,
          positioned: (player) {
            final playerDirection = this.getComponentDirectionFromMe(player);
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
        if (!this.isIdle) {
          this.idle();
        }
        notObserved?.call();
      },
    );
  }

  /// Get angle between enemy and player
  /// player as a base
  double getAngleFomPlayer() {
    Player? player = this.gameRef.player;
    if (player == null) return 0.0;
    return atan2(
      playerRect.center.dy - enemyRect.center.dy,
      playerRect.center.dx - enemyRect.center.dx,
    );
  }

  /// Get angle between enemy and player
  /// enemy position as a base
  double getInverseAngleFomPlayer() {
    Player? player = this.gameRef.player;
    if (player == null) return 0.0;
    return atan2(
      this.position.y - playerRect.center.dy,
      this.position.x - playerRect.center.dx,
    );
  }

  /// Gets player position used how base in calculations
  Rect get playerRect {
    return (gameRef.player is ObjectCollision
            ? (gameRef.player as ObjectCollision).rectCollision
            : gameRef.player?.toRect()) ??
        Rect.zero;
  }

  /// Gets enemy position used how base in calculations
  Rect get enemyRect {
    return (this.isObjectCollision()
        ? (this as ObjectCollision).rectCollision
        : toRect());
  }
}
