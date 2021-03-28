import 'dart:math';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/interval_tick.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// It is used to represent your enemies.
class Enemy extends GameComponent with Attackable {
  /// Height of the Enemy.
  final double height;

  /// Width of the Enemy.
  final double width;

  /// Life of the Enemy.
  double life;

  /// Max life of the Enemy.
  double maxLife;

  bool _isDead = false;

  /// Map available to store times that can be used to control the frequency of any action.
  Map<String, IntervalTick> timers = Map();

  double dtUpdate = 0;

  Enemy({
    @required Position initPosition,
    @required this.height,
    @required this.width,
    this.life = 10,
  }) {
    receivesAttackFrom = ReceivesAttackFromEnum.PLAYER;
    maxLife = life;
    this.position = Rect.fromLTWH(
      initPosition.x,
      initPosition.y,
      width,
      height,
    );
  }

  bool get isDead => _isDead;

  @override
  void update(double dt) {
    super.update(dt);
    dtUpdate = dt;
  }

  void moveTop(double speed) {
    var collision = verifyEnemyCollision(
      position,
      0,
      (speed * -1),
    );

    if (collision) return;

    position = position.translate(0, (speed * -1));
  }

  void moveBottom(double speed) {
    var collision = verifyEnemyCollision(
      position,
      0,
      speed,
    );
    if (collision) return;

    position = position.translate(0, speed);
  }

  void moveLeft(double speed) {
    var collision = verifyEnemyCollision(
      position,
      (speed * -1),
      0,
    );
    if (collision) return;

    position = position.translate((speed * -1), 0);
  }

  void moveRight(double speed) {
    var collision = verifyEnemyCollision(
      position,
      speed,
      0,
    );

    if (collision) return;

    position = position.translate(speed, 0);
  }

  void moveFromAngleDodgeObstacles(double speed, double angle,
      {Function notMove}) {
    double innerSpeed = (speed * dtUpdate);
    double nextX = innerSpeed * cos(angle);
    double nextY = innerSpeed * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(position.center.dx + nextPoint.dx,
            position.center.dy + nextPoint.dy) -
        position.center;

    var collisionX = verifyEnemyCollision(
      position,
      diffBase.dx,
      0,
    );
    var collisionY = verifyEnemyCollision(
      position,
      0,
      diffBase.dy,
    );

    Offset newDiffBase = diffBase;

    if (collisionX) {
      newDiffBase = Offset(0, newDiffBase.dy);
    }
    if (collisionY) {
      newDiffBase = Offset(newDiffBase.dx, 0);
    }

    if (collisionX && !collisionY && newDiffBase.dy != 0) {
      var collisionY = verifyEnemyCollision(
        position,
        0,
        innerSpeed,
      );
      if (!collisionY) newDiffBase = Offset(0, innerSpeed);
    }

    if (collisionY && !collisionX && newDiffBase.dx != 0) {
      var collisionX = verifyEnemyCollision(
        position,
        innerSpeed,
        0,
      );
      if (!collisionX) newDiffBase = Offset(innerSpeed, 0);
    }

    if (newDiffBase == Offset.zero && notMove != null) {
      notMove();
    }
    this.position = position.shift(newDiffBase);
  }

  void moveFromAngle(double speed, double angle) {
    double innerSpeed = (speed * dtUpdate);
    double nextX = innerSpeed * cos(angle);
    double nextY = innerSpeed * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(position.center.dx + nextPoint.dx,
            position.center.dy + nextPoint.dy) -
        position.center;
    this.position = position.shift(diffBase);
  }

  @override
  void receiveDamage(double damage, dynamic from) {
    if (life > 0) {
      life -= damage;
      if (life <= 0) {
        die();
      }
    }
  }

  void addLife(double life) {
    this.life += life;
    if (this.life > maxLife) {
      this.life = maxLife;
    }
  }

  void die() {
    _isDead = true;
  }

  bool checkPassedInterval(String name, int intervalInMilli, double dt) {
    if (this.timers[name] == null ||
        (this.timers[name] != null &&
            this.timers[name].interval != intervalInMilli)) {
      this.timers[name] = IntervalTick(intervalInMilli);
      return true;
    } else {
      return this.timers[name].update(dt);
    }
  }

  @override
  int priority() => PriorityLayer.ENEMY;

  bool verifyEnemyCollision(
    Rect position,
    double translateX,
    double translateY,
  ) {
    var collision = false;
    collision = (this as ObjectCollision).isCollisionPositionTranslate(
      position,
      translateX,
      translateY,
    );
    return collision;
  }
}
