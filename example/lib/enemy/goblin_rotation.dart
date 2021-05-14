import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';

class GoblinRotation extends RotationEnemy {
  GoblinRotation(Vector2 position)
      : super(
          animIdle: SpriteAnimation.load(
            "enemy/goblin_idle.png",
            SpriteAnimationData.sequenced(
              amount: 6,
              stepTime: 0.1,
              textureSize: Vector2(16, 16),
            ),
          ),
          animRun: SpriteAnimation.load(
            "enemy/goblin_run_left.png",
            SpriteAnimationData.sequenced(
              amount: 6,
              stepTime: 0.1,
              textureSize: Vector2(16, 16),
            ),
          ),
          position: position,
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
          animationTop: SpriteAnimation.load(
            "player/fireball_top.png",
            SpriteAnimationData.sequenced(
              amount: 3,
              stepTime: 0.1,
              textureSize: Vector2(23, 23),
            ),
          ),
          animationDestroy: SpriteAnimation.load(
            "player/explosion_fire.png",
            SpriteAnimationData.sequenced(
              amount: 6,
              stepTime: 0.1,
              textureSize: Vector2(32, 32),
            ),
          ),
          width: 25,
          height: 25,
          damage: 10,
          speed: speed * 1.5,
          collision: CollisionConfig(
            collisions: [
              CollisionArea.rectangle(
                size: Size(width / 2, width / 2),
                align: Vector2(width * 0.1, 0),
              ),
            ],
          ),
        );
      },
      radiusVision: DungeonMap.tileSize * 4,
      minDistanceCellsFromPlayer: 3,
    );
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
        animation: SpriteAnimation.load(
          "smoke_explosin.png",
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.1,
            textureSize: Vector2(16, 16),
          ),
        ),
        position: position,
      ),
    );
    remove();
    super.die();
  }
}
