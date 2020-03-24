import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/util/animated_object.dart';
import 'package:bonfire/util/animated_object_once.dart';
import 'package:bonfire/util/direction.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackObject extends AnimatedObject {
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

  FlyingAttackObject({
    @required this.initPosition,
    @required this.flyAnimation,
    @required this.direction,
    @required this.width,
    @required this.height,
    this.destroyAnimation,
    this.speed = 1.5,
    this.damage = 1,
    this.damageInPlayer = true,
    this.damageInEnemy = true,
  }) {
    animation = flyAnimation;
    position = positionInWorld = Rect.fromLTWH(
      initPosition.x,
      initPosition.y,
      width,
      height,
    );
  }

  @override
  void update(double dt) {
    switch (direction) {
      case Direction.left:
        positionInWorld = positionInWorld.translate(speed * -1, 0);
        break;
      case Direction.right:
        positionInWorld = positionInWorld.translate(speed, 0);
        break;
      case Direction.top:
        positionInWorld = positionInWorld.translate(0, speed * -1);
        break;
      case Direction.bottom:
        positionInWorld = positionInWorld.translate(0, speed);
        break;
    }

    if (position.right > gameRef.size.width * 1.5 ||
        position.left < gameRef.size.width * -1.5 ||
        position.bottom > gameRef.size.height * 1.5 ||
        position.top < gameRef.size.height * -1.5) {
      remove();
    }

    _verifyCollision();

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (this.isVisibleInMap()) {
      super.render(canvas);
    }
  }

  void _verifyCollision() {
    bool destroy = false;

    Rect rectCollision = Rect.fromLTWH(
      positionInWorld.left,
      positionInWorld.top + (height / 2),
      width,
      height / 3,
    );

    var collisionsDecorations = List<GameDecoration>();
    var collisions = gameRef.map
        .getCollisionsRendered()
        .where((i) =>
            i.collision &&
            _transformPositionInWord(i.position).overlaps(rectCollision))
        .toList();

    if (gameRef.decorations != null) {
      collisionsDecorations = gameRef.decorations
          .where(
              (i) => i.collision && i.positionInWorld.overlaps(rectCollision))
          .toList();
    }

    destroy = collisions.length > 0 || collisionsDecorations.length > 0;

    if (damageInPlayer) {
      if (position.overlaps(gameRef.player.position)) {
        destroy = true;
        gameRef.player.receiveDamage(damage);
      }
    }

    if (damageInEnemy) {
      gameRef.visibleEnemies().forEach((enemy) {
        if (enemy.positionInWorld.overlaps(positionInWorld)) {
          enemy.receiveDamage(damage);
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
              positionInWorld.left - width,
              positionInWorld.top,
              width,
              height,
            );
            break;
          case Direction.right:
            positionDestroy = Rect.fromLTWH(
              positionInWorld.left + width,
              positionInWorld.top,
              width,
              height,
            );
            break;
          case Direction.top:
            positionDestroy = Rect.fromLTWH(
              positionInWorld.left,
              positionInWorld.top - height,
              width,
              height,
            );
            break;
          case Direction.bottom:
            positionDestroy = Rect.fromLTWH(
              positionInWorld.left,
              positionInWorld.bottom,
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
    }
  }

  _transformPositionInWord(Rect position) => Rect.fromLTWH(
        position.left - gameRef.gameCamera.position.x,
        position.top - gameRef.gameCamera.position.y,
        position.width,
        position.height,
      );
}
