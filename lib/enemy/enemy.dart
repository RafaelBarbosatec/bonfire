import 'dart:math';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/interval_tick.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/components.dart';
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
  late double maxLife;

  bool _isDead = false;

  bool isIdle = true;

  /// Map available to store times that can be used to control the frequency of any action.
  Map<String, IntervalTick> timers = Map();

  double dtUpdate = 0;

  Enemy({
    required Vector2 position,
    required this.height,
    required this.width,
    this.life = 10,
  }) {
    receivesAttackFrom = ReceivesAttackFromEnum.PLAYER;
    maxLife = life;
    this.position = Vector2Rect.fromRect(
      Rect.fromLTWH(
        position.x,
        position.y,
        width,
        height,
      ),
    );
  }

  bool get isDead => _isDead;

  @override
  void update(double dt) {
    super.update(dt);
    dtUpdate = dt;
  }

  /// Move Enemy to up
  void moveUp(double speed) {
    isIdle = false;
    var collision = verifyEnemyTranslateCollision(
      0,
      (speed * -1),
    );

    if (collision) return;

    position = position.translate(0, (speed * -1));
  }

  /// Move Enemy to down
  void moveDown(double speed) {
    isIdle = false;
    var collision = verifyEnemyTranslateCollision(
      0,
      speed,
    );
    if (collision) return;

    position = position.translate(0, speed);
  }

  /// Move Enemy to left
  void moveLeft(double speed) {
    isIdle = false;
    var collision = verifyEnemyTranslateCollision(
      (speed * -1),
      0,
    );
    if (collision) return;

    position = position.translate((speed * -1), 0);
  }

  /// Move Enemy to right
  void moveRight(double speed) {
    isIdle = false;
    var collision = verifyEnemyTranslateCollision(
      speed,
      0,
    );

    if (collision) return;

    position = position.translate(speed, 0);
  }

  /// Move Enemy to up and right
  void moveUpRight(double speedX, double speedY) {
    moveRight(speedX);
    moveUp(speedY);
  }

  /// Move Enemy to up and left
  void moveUpLeft(double speedX, double speedY) {
    moveLeft(speedX);
    moveUp(speedY);
  }

  /// Move Enemy to down and left
  void moveDownLeft(double speedX, double speedY) {
    moveLeft(speedX);
    moveDown(speedY);
  }

  /// Move Enemy to down and right
  void moveDownRight(double speedX, double speedY) {
    moveRight(speedX);
    moveDown(speedY);
  }

  /// Move Enemy to diretion by radAngle with dodge obstacles
  void moveFromAngleDodgeObstacles(
    double speed,
    double angle, {
    Function? notMove,
  }) {
    isIdle = false;
    double innerSpeed = (speed * dtUpdate);
    double nextX = innerSpeed * cos(angle);
    double nextY = innerSpeed * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(position.center.dx + nextPoint.dx,
            position.center.dy + nextPoint.dy) -
        position.center;

    var collisionX = verifyEnemyTranslateCollision(
      diffBase.dx,
      0,
    );
    var collisionY = verifyEnemyTranslateCollision(
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
      var collisionY = verifyEnemyTranslateCollision(
        0,
        innerSpeed,
      );
      if (!collisionY) newDiffBase = Offset(0, innerSpeed);
    }

    if (collisionY && !collisionX && newDiffBase.dx != 0) {
      var collisionX = verifyEnemyTranslateCollision(
        innerSpeed,
        0,
      );
      if (!collisionX) newDiffBase = Offset(innerSpeed, 0);
    }

    if (newDiffBase == Offset.zero) {
      notMove?.call();
    }
    this.position = position.shift(newDiffBase);
  }

  /// Move Enemy to direction by radAngle
  void moveFromAngle(double speed, double angle) {
    isIdle = false;
    double innerSpeed = (speed * dtUpdate);
    double nextX = innerSpeed * cos(angle);
    double nextY = innerSpeed * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(
          position.center.dx + nextPoint.dx,
          position.center.dy + nextPoint.dy,
        ) -
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

  /// increase life in the enemy
  void addLife(double life) {
    this.life += life;
    if (this.life > maxLife) {
      this.life = maxLife;
    }
  }

  void idle() {
    isIdle = true;
  }

  /// marks the enemy as dead
  void die() {
    _isDead = true;
  }

  /// Checks whether you entered a certain configured interval
  /// Used in flows involved in the [update]
  bool checkPassedInterval(String name, int intervalInMilli, double dt) {
    if (this.timers[name]?.interval != intervalInMilli) {
      this.timers[name] = IntervalTick(intervalInMilli);
      return true;
    } else {
      return this.timers[name]?.update(dt) ?? false;
    }
  }

  /// Check if performing a certain translate on the enemy collision occurs
  bool verifyEnemyTranslateCollision(
    double translateX,
    double translateY,
  ) {
    return (this as ObjectCollision).isCollision(
      displacement: this.position.translate(translateX, translateY),
    );
  }
}
