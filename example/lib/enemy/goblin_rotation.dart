import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:example/map/dungeon_map.dart';
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
    this.seeAndMoveToAttackRange(
        positioned: (player) {
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
              collision: CollisionConfig(
                  collisions: [CollisionArea(height: 15, width: 15)]));
        },
        radiusVision: DungeonMap.tileSize * 4,
        minDistanceCellsFromPlayer: 3);
    super.update(dt);
  }

  @override
  void receiveDamage(double damage, dynamic from) {
    this.showDamage(damage);
    super.receiveDamage(damage, from);
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
          position: position),
    );
    remove();
    super.die();
  }
}
