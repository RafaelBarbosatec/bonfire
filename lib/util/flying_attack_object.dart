import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/animated_object.dart';
import 'package:bonfire/util/animated_object_once.dart';
import 'package:bonfire/util/direction.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/position.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackObject extends AnimatedObject with HasGameRef<RPGGame> {
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
  Rect positionInWorld;

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
    position =
        position = Rect.fromLTWH(initPosition.x, initPosition.y, width, height);
    positionInWorld = position;
    positionInWorld = position;
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

    position = Rect.fromLTWH(
      positionInWorld.left + gameRef.mapCamera.x,
      positionInWorld.top + gameRef.mapCamera.y,
      width,
      height,
    );

    if (position.right > gameRef.size.width * 1.5 ||
        position.left < gameRef.size.width * -1.5 ||
        position.bottom > gameRef.size.height * 1.5 ||
        position.top < gameRef.size.height * -1.5) {
      remove();
    }

    if (_verifyCollision()) return;

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (position.top < (gameRef.size.height + height) &&
        position.top > (height * -1) &&
        position.left > (width * -1) &&
        position.left < (gameRef.size.width + width)) {
      super.render(canvas);
    }
  }

  bool _verifyCollision() {
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
      gameRef.enemies.where((i) => i.isVisibleInMap()).forEach((enemy) {
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

    return destroy;
  }

  _transformPositionInWord(Rect position) => Rect.fromLTWH(
        position.left - gameRef.mapCamera.x,
        position.top - gameRef.mapCamera.y,
        position.width,
        position.height,
      );
}
