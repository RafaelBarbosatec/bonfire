import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/objects/animated_object.dart';
import 'package:bonfire/util/objects/animated_object_once.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackObject extends AnimatedObject
    with ObjectCollision, WithLighting {
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
  final LightingConfig lightingConfig;

  final IntervalTick _timerVerifyCollision = IntervalTick(40);

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
    this.lightingConfig,
    Collision collision,
  }) {
    if (lightingConfig != null) lightingConfig.gameComponent = this;
    animation = flyAnimation;
    position = Rect.fromLTWH(
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
        position = position.translate((speed * dt) * -1, 0);
        break;
      case Direction.right:
        position = position.translate((speed * dt), 0);
        break;
      case Direction.top:
        position = position.translate(0, (speed * dt) * -1);
        break;
      case Direction.bottom:
        position = position.translate(0, (speed * dt));
        break;
    }

    if (!_verifyExistInWorld()) {
      remove();
    } else {
      _verifyCollision(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (gameRef != null && gameRef.showCollisionArea) {
      drawCollision(canvas, position, gameRef.collisionAreaColor);
    }
  }

  void _verifyCollision(double dt) {
    if (!_timerVerifyCollision.update(dt)) return;

    bool destroy = false;

    if (withCollision)
      destroy = isCollision(position, gameRef, onlyVisible: false);

    if (damageInPlayer && !destroy) {
      if (position.overlaps(gameRef.player.rectCollision)) {
        gameRef.player.receiveDamage(damage, id);
        destroy = true;
      }
    }

    if (damageInEnemy && !destroy) {
      gameRef
          .livingEnemies()
          .where((enemy) => enemy.rectCollision.overlaps(position))
          .forEach((enemy) {
        enemy.receiveDamage(damage, id);
        destroy = true;
      });
    }

    if (destroy) {
      if (destroyAnimation != null) {
        Rect positionDestroy;
        switch (direction) {
          case Direction.left:
            positionDestroy = Rect.fromLTWH(
              position.left - (width / 2),
              position.top,
              width,
              height,
            );
            break;
          case Direction.right:
            positionDestroy = Rect.fromLTWH(
              position.left + (width / 2),
              position.top,
              width,
              height,
            );
            break;
          case Direction.top:
            positionDestroy = Rect.fromLTWH(
              position.left,
              position.top - (height / 2),
              width,
              height,
            );
            break;
          case Direction.bottom:
            positionDestroy = Rect.fromLTWH(
              position.left,
              position.top + (height / 2),
              width,
              height,
            );
            break;
        }

        gameRef.add(
          AnimatedObjectOnce(
            animation: destroyAnimation,
            position: positionDestroy,
            lightingConfig: lightingConfig,
          ),
        );
      }
      remove();
      if (this.destroyedObject != null) this.destroyedObject();
    }
  }

  bool _verifyExistInWorld() {
    bool result = true;
    if (position.left < gameRef.gameCamera.position.x) {
      result = false;
    }
    if (position.right >
        gameRef.gameCamera.position.x + gameRef.map.mapSize.width) {
      result = false;
    }
    if (position.top < gameRef.gameCamera.position.y) {
      result = false;
    }
    if (position.bottom >
        gameRef.gameCamera.position.y + gameRef.map.mapSize.height) {
      result = false;
    }

    return result;
  }
}
