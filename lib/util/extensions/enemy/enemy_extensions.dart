import 'dart:math';

import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/extensions/game_component_extensions.dart';
import 'package:bonfire/util/extensions/movement_extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

/// Functions util to use in your [Enemy]
extension EnemyExtensions on Enemy {
  /// This method we notify when detect the player when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  void seePlayer({
    required Function(Player) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    Player? player = gameRef.player;
    if (player == null || player.isDead) {
      notObserved?.call();
      return;
    }
    this.seeComponent(
      player,
      observed: (c) => observed(c as Player),
      notObserved: notObserved,
      radiusVision: radiusVision,
    );
  }

  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToPlayer({
    required Function(Player) closePlayer,
    VoidCallback? notObserved,
    VoidCallback? observed,
    double radiusVision = 32,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;
    if (runOnlyVisibleInScreen && !this.isVisible) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        observed?.call();
        this.followComponent(
          player,
          dtUpdate,
          closeComponent: (comp) => closePlayer(comp as Player),
          margin: margin,
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
    int? id,
    double speed = 150,
    double damage = 1,
    Direction? direction,
    int interval = 1000,
    bool withCollision = true,
    bool enableDiagonal = true,
    CollisionConfig? collision,
    VoidCallback? destroy,
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
      destroy: destroy,
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
      playerRect.center.dy - this.center.x,
      playerRect.center.dx - this.center.y,
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
}
