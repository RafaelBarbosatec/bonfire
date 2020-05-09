import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/objects/animated_object.dart';
import 'package:bonfire/util/objects/animated_object_once.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackObject extends AnimatedObject with ObjectCollision {
  final int id;
  final FlameAnimation.Animation flyAnimation;
  final FlameAnimation.Animation destroyAnimation;
  final Direction direction;
  final double speed;
  final double damage;
  final double width;
  final double height;
  final Position initPosition;
  final bool damageInPlayer;
  final bool damageInEnemy;
  final bool withCollision;
  final VoidCallback destroyedObject;

  FlyingAttackObject({
    @required this.initPosition,
    @required this.flyAnimation,
    @required this.direction,
    @required this.width,
    @required this.height,
    this.id,
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
    positionInWorld = Rect.fromLTWH(
      initPosition.x,
      initPosition.y,
      width,
      height,
    );

    this.collision = collision ?? Collision(width: width, height: height / 2);
  }

  @override
  void update(double dt) {
    super.update(dt);

    switch (direction) {
      case Direction.left:
        positionInWorld = positionInWorld.translate((speed * dt) * -1, 0);
        break;
      case Direction.right:
        positionInWorld = positionInWorld.translate((speed * dt), 0);
        break;
      case Direction.top:
        positionInWorld = positionInWorld.translate(0, (speed * dt) * -1);
        break;
      case Direction.bottom:
        positionInWorld = positionInWorld.translate(0, (speed * dt));
        break;
    }

    if (this.position == null) return;
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
      super.render(canvas);
    }
    if (gameRef != null && gameRef.showCollisionArea) {
      drawCollision(canvas, position, gameRef.collisionAreaColor);
    }
  }

  void _verifyCollision() {
    bool destroy = false;

    if (withCollision)
      destroy = isCollisionPositionInWorld(positionInWorld, gameRef);

    if (damageInPlayer) {
      if (position.overlaps(gameRef.player.rectCollision)) {
        gameRef.player.receiveDamage(damage, id);
        destroy = true;
      }
    }

    if (damageInEnemy) {
      gameRef.visibleEnemies().forEach((enemy) {
        if (enemy.rectCollisionInWorld.overlaps(positionInWorld)) {
          enemy.receiveDamage(damage, id);
          destroy = true;
        }
      });
    }

    if (destroy) {
      if (destroyAnimation != null) {
        Rect positionDestroy;
        switch (direction) {
          case Direction.left:
            positionDestroy = Rect.fromLTWH(
              positionInWorld.left - (width / 2),
              positionInWorld.top,
              width,
              height,
            );
            break;
          case Direction.right:
            positionDestroy = Rect.fromLTWH(
              positionInWorld.left + (width / 2),
              positionInWorld.top,
              width,
              height,
            );
            break;
          case Direction.top:
            positionDestroy = Rect.fromLTWH(
              positionInWorld.left,
              positionInWorld.top - (height / 2),
              width,
              height,
            );
            break;
          case Direction.bottom:
            positionDestroy = Rect.fromLTWH(
              positionInWorld.left,
              positionInWorld.top + (height / 2),
              width,
              height,
            );
            break;
        }

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
