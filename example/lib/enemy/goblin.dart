import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/util/common_sprite_sheet.dart';
import 'package:example/util/enemy_sprite_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Goblin extends SimpleEnemy with ObjectCollision {
  double attack = 20;
  bool _seePlayerClose = false;

  Goblin(Vector2 position)
      : super(
          animation: EnemySpriteSheet.simpleDirectionAnimation,
          position: position,
          width: DungeonMap.tileSize * 0.8,
          height: DungeonMap.tileSize * 0.8,
          speed: DungeonMap.tileSize * 1.6,
          life: 100,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea(
            height: DungeonMap.tileSize * 0.7,
            width: DungeonMap.tileSize * 0.4,
            align: Offset(
              DungeonMap.tileSize * 0.2,
              0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (this.isDead) return;

    _seePlayerClose = false;
    this.seePlayer(
      observed: (player) {
        _seePlayerClose = true;
        this.seeAndMoveToPlayer(
          closePlayer: (player) {
            execAttack();
          },
          radiusVision: DungeonMap.tileSize * 2,
        );
      },
      radiusVision: DungeonMap.tileSize * 2,
    );

    if (!_seePlayerClose) {
      this.seeAndMoveToAttackRange(
        minDistanceFromPlayer: DungeonMap.tileSize * 4,
        positioned: (p) {
          execAttackRange();
        },
        radiusVision: DungeonMap.tileSize * 5,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    this.drawDefaultLifeBar(canvas);
  }

  @override
  void die() {
    gameRef.add(
      AnimatedObjectOnce(
        animation: CommonSpriteSheet.smokeExplosion,
        position: position,
      ),
    );
    remove();
    super.die();
  }

  void execAttackRange() {
    if (gameRef.player != null && gameRef.player.isDead) return;
    this.simpleAttackRange(
      animationRight: CommonSpriteSheet.fireBallRight,
      animationLeft: CommonSpriteSheet.fireBallLeft,
      animationTop: CommonSpriteSheet.fireBallTop,
      animationBottom: CommonSpriteSheet.fireBallBottom,
      animationDestroy: CommonSpriteSheet.explosionAnimation,
      id: 35,
      width: width * 0.9,
      height: width * 0.9,
      damage: attack,
      speed: DungeonMap.tileSize * 3,
      collision: CollisionConfig(
        collisions: [
          CollisionArea(
            width: width / 2,
            height: width / 2,
            align: Offset(
              width * 0.2,
              width * 0.2,
            ),
          ),
        ],
      ),
      lightingConfig: LightingConfig(
        radius: width,
        blurBorder: width * 0.5,
      ),
    );
  }

  void execAttack() {
    if (gameRef.player != null && gameRef.player.isDead) return;
    this.simpleAttackMelee(
      height: width,
      width: width,
      damage: attack / 2,
      interval: 400,
      attackEffectBottomAnim: CommonSpriteSheet.blackAttackEffectBottom,
      attackEffectLeftAnim: CommonSpriteSheet.blackAttackEffectLeft,
      attackEffectRightAnim: CommonSpriteSheet.blackAttackEffectRight,
      attackEffectTopAnim: CommonSpriteSheet.blackAttackEffectTop,
    );
  }

  @override
  void receiveDamage(double damage, dynamic from) {
    this.showDamage(
      damage,
      config: TextConfig(
        fontSize: width / 3,
        color: Colors.white,
      ),
    );
    super.receiveDamage(damage, from);
  }
}
