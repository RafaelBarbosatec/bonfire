import 'dart:math';

import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/enemy/extensions.dart';
import 'package:bonfire/enemy/rotation/rotation_enemy.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:bonfire/objects/flying_attack_angle_object.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
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
    if (runOnlyVisibleInScreen && !this.isVisibleInCamera()) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        double _radAngle = getAngleFomPlayer();

        Vector2Rect playerRect = player is ObjectCollision
            ? (player as ObjectCollision).rectCollision
            : player.position;
        Rect rectPlayerCollision = Rect.fromLTWH(
          playerRect.rect.left - margin,
          playerRect.rect.top - margin,
          playerRect.rect.width + (margin * 2),
          playerRect.rect.height + (margin * 2),
        );

        Vector2Rect rectToMove = this.isObjectCollision()
            ? (this as ObjectCollision).rectCollision
            : position;

        if (rectToMove.rect.overlaps(rectPlayerCollision)) {
          closePlayer(player);
          this.idle();
          this.moveFromAngleDodgeObstacles(0, _radAngle);
          return;
        }

        this.moveFromAngleDodgeObstacles(speed, _radAngle, notMove: () {
          this.idle();
        });
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
    if (runOnlyVisibleInScreen && !this.isVisibleInCamera()) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        positioned(player);

        Vector2Rect playerRect = player is ObjectCollision
            ? (player as ObjectCollision).rectCollision
            : player.position;
        double distance = (minDistanceCellsFromPlayer ?? radiusVision);
        double _radAngle = getAngleFomPlayer();

        Vector2 myPosition = Vector2(
          this.position.center.dx,
          this.position.center.dy,
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
          notMove: () {
            this.idle();
          },
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
    required double height,
    required double width,
    int? id,
    bool withPush = false,
    double? radAngleDirection,
    VoidCallback? execute,
    int interval = 1000,
  }) {
    if (!this.checkPassedInterval('attackMelee', interval, dtUpdate)) return;

    if (isDead) return;

    double angle = radAngleDirection ?? this.currentRadAngle;

    double nextX = this.height * cos(angle);
    double nextY = this.height * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(this.position.center.dx + nextPoint.dx,
            this.position.center.dy + nextPoint.dy) -
        this.position.center;

    Vector2Rect positionAttack = this.position.shift(diffBase);

    gameRef.add(AnimatedObjectOnce(
      animation: attackEffectTopAnim,
      position: positionAttack,
      rotateRadAngle: angle,
    ));

    gameRef
        .visibleAttackables()
        .where((a) =>
            a.receivesAttackFromEnemy() &&
            a.rectAttackable().rect.overlaps(positionAttack.rect))
        .forEach((attackable) {
      attackable.receiveDamage(damage, id);
      Vector2Rect rectAfterPush =
          attackable.position.translate(diffBase.dx, diffBase.dy);
      if (withPush &&
          (attackable is ObjectCollision &&
              !(attackable as ObjectCollision)
                  .isCollision(displacement: rectAfterPush))) {
        attackable.position = rectAfterPush;
      }
    });

    if (execute != null) execute();
  }

  /// Execute the ranged attack using a component with animation
  void simpleAttackRange({
    required Future<SpriteAnimation> animationTop,
    required Future<SpriteAnimation> animationDestroy,
    required double width,
    required double height,
    int? id,
    double speed = 150,
    double damage = 1,
    double? radAngleDirection,
    int interval = 1000,
    bool withCollision = true,
    VoidCallback? destroy,
    CollisionConfig? collision,
    VoidCallback? execute,
    LightingConfig? lightingConfig,
  }) {
    if (!this.checkPassedInterval('attackRange', interval, dtUpdate)) return;

    if (isDead) return;

    double _radAngle = radAngleDirection ?? getAngleFomPlayer();

    double nextX = this.height * cos(_radAngle);
    double nextY = this.height * sin(_radAngle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(this.position.center.dx + nextPoint.dx,
            this.position.center.dy + nextPoint.dy) -
        this.position.center;

    Rect position = this.position.rect.shift(diffBase);
    gameRef.add(
      FlyingAttackAngleObject(
        id: id,
        position: Vector2(position.left, position.top),
        radAngle: _radAngle,
        width: width,
        height: height,
        damage: damage,
        speed: speed,
        damageInPlayer: true,
        collision: collision,
        withCollision: withCollision,
        destroyedObject: destroy,
        flyAnimation: animationTop,
        destroyAnimation: animationDestroy,
        lightingConfig: lightingConfig,
      ),
    );

    if (execute != null) execute();
  }
}
