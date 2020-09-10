import 'dart:math';

import 'package:bonfire/enemy/extensions.dart';
import 'package:bonfire/enemy/rotation/rotation_enemy.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:bonfire/objects/flying_attack_angle_object.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

extension RotationEnemyExtensions on RotationEnemy {
  void seeAndMoveToPlayer({
    Function(Player) closePlayer,
    double radiusVision = 32,
    double margin = 10,
  }) {
    if ((this.collisionOnlyVisibleScreen && !isVisibleInCamera()) ||
        isDead ||
        this.position == null) return;
    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        double _radAngle = getAngleFomPlayer();

        Rect rectPlayerCollision = Rect.fromLTWH(
          player.rectCollision.left - margin,
          player.rectCollision.top - margin,
          player.rectCollision.width + (margin * 2),
          player.rectCollision.height + (margin * 2),
        );

        if (this.rectCollision.overlaps(rectPlayerCollision)) {
          if (closePlayer != null) closePlayer(player);
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

  void seeAndMoveToAttackRange(
      {Function(Player) positioned,
      double radiusVision = 32,
      double minDistanceCellsFromPlayer}) {
    if ((this.collisionOnlyVisibleScreen && !isVisibleInCamera()) ||
        isDead ||
        this.position == null) return;
    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        if (positioned != null) positioned(player);

        double distance = (minDistanceCellsFromPlayer ?? radiusVision);
        double _radAngle = getAngleFomPlayer();

        Position myPosition = Position.fromOffset(this.position.center);
        Position playerPosition =
            Position.fromOffset(player.rectCollision.center);
        double dist = myPosition.distance(playerPosition);

        if (dist >= distance) {
          this.moveFromAngleDodgeObstacles(0, _radAngle);
          this.idle();
          return;
        }

        this.moveFromAngleDodgeObstacles(speed, getInverseAngleFomPlayer(),
            notMove: () {
          this.idle();
        });
      },
      notObserved: () {
        this.idle();
      },
    );
  }

  void simpleAttackMelee({
    @required FlameAnimation.Animation attackEffectTopAnim,
    @required double damage,
    int id,
    double heightArea = 32,
    double widthArea = 32,
    bool withPush = false,
    double radAngleDirection,
    VoidCallback execute,
    int interval = 1000,
  }) {
    if (!this.checkPassedInterval('attackMelee', interval, dtUpdate)) return;

    Player player = gameRef.player;

    if (isDead || this.position == null) return;

    double angle = radAngleDirection ?? this.currentRadAngle;

    double nextX = this.height * cos(angle);
    double nextY = this.height * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(this.position.center.dx + nextPoint.dx,
            this.position.center.dy + nextPoint.dy) -
        this.position.center;

    Rect positionAttack = this.position.shift(diffBase);

    gameRef.addLater(AnimatedObjectOnce(
      animation: attackEffectTopAnim,
      position: positionAttack,
      rotateRadAngle: angle,
    ));

    if (positionAttack.overlaps(player.position)) {
      player.receiveDamage(damage, id);

      if (withPush) {
        Rect rectAfterPush =
            player.position.translate(diffBase.dx, diffBase.dy);
        if (!player.isCollision(rectAfterPush, this.gameRef)) {
          player.position = rectAfterPush;
        }
      }
    }

    if (execute != null) execute();
  }

  void simpleAttackRange({
    @required FlameAnimation.Animation animationTop,
    @required FlameAnimation.Animation animationDestroy,
    @required double width,
    @required double height,
    int id,
    double speed = 150,
    double damage = 1,
    double radAngleDirection,
    int interval = 1000,
    bool withCollision = true,
    bool collisionOnlyVisibleObjects = true,
    VoidCallback destroy,
    Collision collision,
    VoidCallback execute,
    LightingConfig lightingConfig,
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

    Rect position = this.position.shift(diffBase);
    gameRef.addLater(FlyingAttackAngleObject(
      id: id,
      initPosition: Position(position.left, position.top),
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
      collisionOnlyVisibleObjects: collisionOnlyVisibleObjects,
    ));

    if (execute != null) execute();
  }
}
