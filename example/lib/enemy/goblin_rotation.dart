import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class GoblinRotation extends RotationEnemy {
  GoblinRotation(Position initPosition)
      : super(
          animIdle: FlameAnimation.Animation.sequenced(
            "enemy/goblin_idle.png",
            6,
            textureWidth: 16,
            textureHeight: 16,
          ),
          animRun: FlameAnimation.Animation.sequenced(
            "enemy/goblin_run_left.png",
            6,
            textureWidth: 16,
            textureHeight: 16,
          ),
          initPosition: initPosition,
          width: 25,
          height: 25,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    this.drawDefaultLifeBar(canvas);
  }

  @override
  void update(double dt) {
    this.seeAndMoveToPlayer(
        closePlayer: (player) {
          this.simpleAttackRange(
              animationTop: FlameAnimation.Animation.sequenced(
                'player/fireball_top.png',
                3,
                textureWidth: 23,
                textureHeight: 23,
              ),
              animationDestroy: FlameAnimation.Animation.sequenced(
                'player/explosion_fire.png',
                6,
                textureWidth: 32,
                textureHeight: 32,
              ),
              width: 25,
              height: 25,
              damage: 10,
              speed: speed * 1.5,
              collision: Collision(height: 15, width: 15));
        },
        visionCells: 5,
        margin: 64);
    super.update(dt);
  }

  @override
  void receiveDamage(double damage) {
    this.showDamage(damage);
    super.receiveDamage(damage);
  }

  @override
  void die() {
    gameRef.add(
      AnimatedObjectOnce(
          animation: FlameAnimation.Animation.sequenced(
            "smoke_explosin.png",
            6,
            textureWidth: 16,
            textureHeight: 16,
          ),
          position: positionInWorld),
    );
    remove();
    super.die();
  }
}
