import 'dart:math';

import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/enemy/rotation_enemy.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

extension RotationEnemyExtensions on RotationEnemy {
  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToPlayer({
    required Function(Player) closePlayer,
    double radiusVision = 32,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;
    if (runOnlyVisibleInScreen && !this.isVisible) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        double _radAngle = getAngleFomPlayer();

        Rect playerRect = player is ObjectCollision
            ? (player as ObjectCollision).rectCollision
            : player.toRect();
        Rect rectPlayerCollision = Rect.fromLTWH(
          playerRect.left - margin,
          playerRect.top - margin,
          playerRect.width + (margin * 2),
          playerRect.height + (margin * 2),
        );

        Rect rectToMove = this.isObjectCollision()
            ? (this as ObjectCollision).rectCollision
            : toRect();

        if (rectToMove.overlaps(rectPlayerCollision)) {
          closePlayer(player);
          this.idle();
          this.moveFromAngleDodgeObstacles(0, _radAngle);
          return;
        }

        this.moveFromAngleDodgeObstacles(speed, _radAngle, onCollision: idle);
      },
      notObserved: () {
        this.idle();
      },
    );
  }

  /// Checks whether the player is within range. If so, move to it.
  void seeAndMoveToAttackRange({
    required Function(Player) positioned,
    double radiusVision = 32,
    double? minDistanceCellsFromPlayer,
    bool runOnlyVisibleInScreen = true,
  }) {
    if (isDead) return;
    if (runOnlyVisibleInScreen && !this.isVisible) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        positioned(player);

        Rect playerRect = player is ObjectCollision
            ? (player as ObjectCollision).rectCollision
            : player.toRect();
        double distance = (minDistanceCellsFromPlayer ?? radiusVision);
        double _radAngle = getAngleFomPlayer();

        Vector2 myPosition = Vector2(
          this.center.x,
          this.center.y,
        );

        Vector2 playerPosition = Vector2(
          playerRect.center.dx,
          playerRect.center.dy,
        );

        double dist = myPosition.distanceTo(playerPosition);

        if (dist >= distance) {
          this.moveFromAngleDodgeObstacles(0, _radAngle);
          this.idle();
          return;
        }

        this.moveFromAngleDodgeObstacles(
          speed,
          getInverseAngleFomPlayer(),
          onCollision: idle,
        );
      },
      notObserved: () {
        this.idle();
      },
    );
  }

  ///Execute simple attack melee using animation
  void simpleAttackMelee({
    required Future<SpriteAnimation> attackEffectTopAnim,
    required double damage,
    required Vector2 size,
    int? id,
    bool withPush = false,
    double? radAngleDirection,
    VoidCallback? execute,
    int interval = 1000,
  }) {
    if (!this.checkInterval('attackMelee', interval, dtUpdate)) return;

    if (isDead) return;

    double angle = radAngleDirection ?? this.currentRadAngle;

    double nextX = this.height * cos(angle);
    double nextY = this.height * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Vector2 diffBase =
        Vector2(this.center.x + nextPoint.dx, this.position.y + nextPoint.dy) -
            this.center;

    Rect positionAttack = this.toRect().shift(diffBase.toOffset());

    gameRef.add(AnimatedObjectOnce(
      animation: attackEffectTopAnim,
      position: positionAttack.positionVector2,
      size: size,
      rotateRadAngle: angle,
    ));

    gameRef
        .visibleAttackables()
        .where((a) =>
            a.receivesAttackFromEnemy() &&
            a.rectAttackable().overlaps(positionAttack))
        .forEach((attackable) {
      attackable.receiveDamage(damage, id);
      final rectAfterPush = attackable.position.translate(
        diffBase.x,
        diffBase.y,
      );
      if (withPush &&
          (attackable is ObjectCollision &&
              !(attackable as ObjectCollision)
                  .isCollision(displacement: rectAfterPush)
                  .isNotEmpty)) {
        attackable.position = rectAfterPush;
      }
    });

    if (execute != null) execute();
  }

  /// Execute the ranged attack using a component with animation
  void simpleAttackRange({
    required Future<SpriteAnimation> animationUp,
    required Future<SpriteAnimation> animationDestroy,
    required Vector2 size,
    double? radAngleDirection,
    int? id,
    double speed = 150,
    double damage = 1,
    int interval = 1000,
    bool withCollision = true,
    VoidCallback? onDestroy,
    CollisionConfig? collision,
    VoidCallback? onExecute,
    LightingConfig? lightingConfig,
  }) {
    if (!this.checkInterval('attackRange', interval, dtUpdate)) return;

    if (isDead) return;

    this.simpleAttackRangeByAngle(
      animationUp: animationUp,
      animationDestroy: animationDestroy,
      size: size,
      radAngleDirection: radAngleDirection ?? this.currentRadAngle,
      id: id,
      speed: speed,
      damage: damage,
      withCollision: withCollision,
      onDestroy: onDestroy,
      collision: collision,
      lightingConfig: lightingConfig,
    );

    onExecute?.call();
  }
}
