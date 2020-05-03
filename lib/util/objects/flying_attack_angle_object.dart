import 'dart:math';

import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/objects/animated_object.dart';
import 'package:bonfire/util/objects/animated_object_once.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackAngleObject extends AnimatedObject with ObjectCollision {
  final FlameAnimation.Animation flyAnimation;
  final FlameAnimation.Animation destroyAnimation;
  final double radAngle;
  final double speed;
  final double damage;
  final double width;
  final double height;
  final Position initPosition;
  final bool damageInPlayer;
  final bool damageInEnemy;
  final bool withCollision;
  final VoidCallback destroyedObject;

  double _cosAngle;
  double _senAngle;
  double _rotate;

  FlyingAttackAngleObject({
    @required this.initPosition,
    @required this.flyAnimation,
    @required this.radAngle,
    @required this.width,
    @required this.height,
    this.destroyAnimation,
    this.speed = 150,
    this.damage = 1,
    this.damageInPlayer = true,
    this.damageInEnemy = true,
    this.withCollision = true,
    this.destroyedObject,
    Collision collision,
  }) {
    animation = flyAnimation;
    position = positionInWorld = Rect.fromLTWH(
      initPosition.x,
      initPosition.y,
      width,
      height,
    );

    this.collision = collision ?? Collision(width: width, height: height / 2);
    _cosAngle = cos(radAngle);
    _senAngle = sin(radAngle);
    _rotate = radAngle == 0.0 ? 0.0 : radAngle + (pi / 2);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double nextX = (speed * dt) * _cosAngle;
    double nextY = (speed * dt) * _senAngle;
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(positionInWorld.center.dx + nextPoint.dx,
            positionInWorld.center.dy + nextPoint.dy) -
        positionInWorld.center;

    positionInWorld = positionInWorld.shift(diffBase);

    if (position.right > gameRef.size.width * 1.5 ||
        position.left < gameRef.size.width * -0.5 ||
        position.bottom > gameRef.size.height * 1.5 ||
        position.top < gameRef.size.height * -0.5) {
      remove();
    }

    _verifyCollision();
  }

  @override
  void render(Canvas canvas) {
    if (this.isVisibleInMap()) {
      canvas.save();
      canvas.translate(position.center.dx, position.center.dy);
      canvas.rotate(_rotate);
      canvas.translate(-position.center.dx, -position.center.dy);
      super.render(canvas);
      if (gameRef != null && gameRef.showCollisionArea) {
        drawCollision(canvas, position, gameRef.collisionAreaColor);
      }
      canvas.restore();
    }
  }

  void _verifyCollision() {
    bool destroy = false;

    if (withCollision)
      destroy = isCollisionPositionInWorld(positionInWorld, gameRef);

    if (damageInPlayer) {
      if (position.overlaps(gameRef.player.rectCollision)) {
        gameRef.player.receiveDamage(damage);
        destroy = true;
      }
    }

    if (damageInEnemy) {
      gameRef.visibleEnemies().forEach((enemy) {
        if (enemy.rectCollisionInWorld.overlaps(positionInWorld)) {
          enemy.receiveDamage(damage);
          destroy = true;
        }
      });
    }

    if (destroy) {
      if (destroyAnimation != null) {
        double nextX = (width / 2) * _cosAngle;
        double nextY = (height / 2) * _senAngle;
        Offset nextPoint = Offset(nextX, nextY);

        Offset diffBase = Offset(positionInWorld.center.dx + nextPoint.dx,
                positionInWorld.center.dy + nextPoint.dy) -
            positionInWorld.center;

        Rect positionDestroy = positionInWorld.shift(diffBase);

        gameRef.add(
          AnimatedObjectOnce(
            animation: destroyAnimation,
            position: positionDestroy,
          ),
        );
      }
      remove();
      if (this.destroyedObject != null) this.destroyedObject();
    }
  }
}
