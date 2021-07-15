import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/enemy/simple_enemy.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/extensions/enemy/enemy_extensions.dart';
import 'package:bonfire/util/extensions/movement_extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

extension SimpleEnemyExtensions on SimpleEnemy {
  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToPlayer({
    required Function(Player) closePlayer,
    double radiusVision = 32,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;
    if (runOnlyVisibleInScreen && !this.isVisibleInCamera()) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
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
      },
    );
  }

  ///Execute simple attack melee using animation
  void simpleAttackMelee({
    required double damage,
    required double height,
    required double width,
    int? id,
    int interval = 1000,
    bool withPush = false,
    double? sizePush,
    Direction? direction,
    Future<SpriteAnimation>? attackEffectRightAnim,
    Future<SpriteAnimation>? attackEffectBottomAnim,
    Future<SpriteAnimation>? attackEffectLeftAnim,
    Future<SpriteAnimation>? attackEffectTopAnim,
    VoidCallback? execute,
  }) {
    if (!this.checkInterval('attackMelee', interval, dtUpdate)) return;

    if (isDead) return;

    Direction direct = direction ?? getComponentDirectionFromMe(gameRef.player);

    this.simpleAttackMeleeByDirection(
      damage: damage,
      direction: direct,
      height: height,
      width: width,
      id: id,
      withPush: withPush,
      sizePush: sizePush,
      animationTop: attackEffectTopAnim,
      animationBottom: attackEffectBottomAnim,
      animationLeft: attackEffectLeftAnim,
      animationRight: attackEffectRightAnim,
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
    required double width,
    required double height,
    int? id,
    double speed = 150,
    double damage = 1,
    Direction? direction,
    int interval = 1000,
    bool withCollision = true,
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
      width: width,
      height: height,
      direction: direct,
      id: id,
      speed: speed,
      damage: damage,
      withCollision: withCollision,
      collision: collision,
      destroy: destroy,
      lightingConfig: lightingConfig,
    );

    if (execute != null) execute();
  }

  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToAttackRange({
    required Function(Player) positioned,
    double radiusVision = 32,
    double? minDistanceFromPlayer,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        this.positionsItselfAndKeepDistance(
          player,
          minDistanceFromPlayer: minDistanceFromPlayer,
          radiusVision: radiusVision,
          runOnlyVisibleInScreen: runOnlyVisibleInScreen,
          positioned: (player) {
            positioned(player as Player);
          },
        );
      },
      notObserved: () {
        if (!this.isIdle) {
          this.idle();
        }
      },
    );
  }
}
