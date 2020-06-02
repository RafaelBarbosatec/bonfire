import 'package:bonfire/bonfire.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Goblin extends SimpleEnemy {
  double attack = 25;
  bool _seePlayerClose = false;

  Goblin(Position initPosition)
      : super(
            animationIdleRight: FlameAnimation.Animation.sequenced(
              "enemy/goblin_idle.png",
              6,
              textureWidth: 16,
              textureHeight: 16,
            ),
            animationIdleLeft: FlameAnimation.Animation.sequenced(
              "enemy/goblin_idle_left.png",
              6,
              textureWidth: 16,
              textureHeight: 16,
            ),
            animationRunRight: FlameAnimation.Animation.sequenced(
              "enemy/goblin_run_right.png",
              6,
              textureWidth: 16,
              textureHeight: 16,
            ),
            animationRunLeft: FlameAnimation.Animation.sequenced(
              "enemy/goblin_run_left.png",
              6,
              textureWidth: 16,
              textureHeight: 16,
            ),
            initPosition: initPosition,
            width: DungeonMap.tileSize * 0.8,
            height: DungeonMap.tileSize * 0.8,
            speed: DungeonMap.tileSize * 2,
            life: 100,
            collision: Collision(
              height: DungeonMap.tileSize * 0.4,
              width: DungeonMap.tileSize * 0.4,
              align: CollisionAlign.CENTER,
            ));

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
            visionCells: 3,
          );
        },
        visionCells: 3);

    if (!_seePlayerClose) {
      this.seeAndMoveToAttackRange(
        positioned: (p) {
          execAttackRange();
        },
        visionCells: 8,
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
        animation: FlameAnimation.Animation.sequenced(
          "smoke_explosin.png",
          6,
          textureWidth: 16,
          textureHeight: 16,
        ),
        position: position,
      ),
    );
    remove();
    super.die();
  }

  void execAttackRange() {
    if (gameRef.player != null && gameRef.player.isDead) return;
    this.simpleAttackRange(
      animationRight: FlameAnimation.Animation.sequenced(
        'player/fireball_right.png',
        3,
        textureWidth: 23,
        textureHeight: 23,
      ),
      animationLeft: FlameAnimation.Animation.sequenced(
        'player/fireball_left.png',
        3,
        textureWidth: 23,
        textureHeight: 23,
      ),
      animationTop: FlameAnimation.Animation.sequenced(
        'player/fireball_top.png',
        3,
        textureWidth: 23,
        textureHeight: 23,
      ),
      animationBottom: FlameAnimation.Animation.sequenced(
        'player/fireball_bottom.png',
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
      id: 35,
      width: width * 0.9,
      height: width * 0.9,
      damage: attack,
      speed: speed * 2,
      lightingConfig: LightingConfig(
        gameComponent: this,
        color: Colors.orange.withOpacity(0.1),
        radius: 25,
        blurBorder: 20,
      ),
    );
  }

  void execAttack() {
    if (gameRef.player != null && gameRef.player.isDead) return;
    this.simpleAttackMelee(
      heightArea: width,
      widthArea: width,
      damage: attack / 2,
      interval: 400,
      attackEffectBottomAnim: FlameAnimation.Animation.sequenced(
        'enemy/atack_effect_bottom.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
      attackEffectLeftAnim: FlameAnimation.Animation.sequenced(
        'enemy/atack_effect_left.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
      attackEffectRightAnim: FlameAnimation.Animation.sequenced(
        'enemy/atack_effect_right.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
      attackEffectTopAnim: FlameAnimation.Animation.sequenced(
        'enemy/atack_effect_top.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
    );
  }

  @override
  void receiveDamage(double damage, int from) {
    this.showDamage(damage);
    super.receiveDamage(damage, from);
  }
}
