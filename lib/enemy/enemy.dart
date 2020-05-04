import 'dart:async';
import 'dart:ui';

import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/objects/animated_object.dart';
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// It is used to represent your enemies.
class Enemy extends AnimatedObject with ObjectCollision {
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
  Map<String, Timer> timers = Map();

  double dtUpdate = 0;

  Enemy(
      {@required Position initPosition,
      @required this.height,
      @required this.width,
      this.life = 10,
      Collision collision}) {
    maxLife = life;
    this.positionInWorld = Rect.fromLTWH(
      initPosition.x,
      initPosition.y,
      width,
      height,
    );
    this.collision = collision ?? Collision(width: width, height: height / 2);
  }

  bool get isDead => _isDead;

  @override
  void render(Canvas canvas) {
    if (isVisibleInMap()) {
      super.render(canvas);
      if (gameRef != null && gameRef.showCollisionArea) {
        drawCollision(canvas, position, gameRef.collisionAreaColor);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    dtUpdate = dt;
  }

  void translate(double translateX, double translateY) {
    positionInWorld = positionInWorld.translate(translateX, translateY);
  }

  void moveTop(double speed) {
    var collision = isCollisionTranslate(
      position,
      0,
      (speed * -1),
      gameRef,
    );

    if (collision) return;

    positionInWorld = positionInWorld.translate(0, (speed * -1));
  }

  void moveBottom(double speed) {
    var collision = isCollisionTranslate(
      position,
      0,
      speed,
      gameRef,
    );
    if (collision) return;

    positionInWorld = positionInWorld.translate(0, speed);
  }

  void moveLeft(double speed) {
    var collision = isCollisionTranslate(
      position,
      (speed * -1),
      0,
      gameRef,
    );
    if (collision) return;

    positionInWorld = positionInWorld.translate((speed * -1), 0);
  }

  void moveRight(double speed) {
    var collision = isCollisionTranslate(
      position,
      speed,
      0,
      gameRef,
    );

    if (collision) return;

    positionInWorld = positionInWorld.translate(speed, 0);
  }

  void receiveDamage(double damage) {
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

  bool checkPassedInterval(String name, int intervalInMilli) {
    if (this.timers[name] == null) {
      this.timers[name] = Timer(
        Duration(milliseconds: intervalInMilli),
        () {
          this.timers[name] = null;
        },
      );
      return true;
    } else {
      return false;
    }
  }

  Rect get rectCollision => getRectCollision(position);
  Rect get rectCollisionInWorld => getRectCollision(positionInWorld);
}
