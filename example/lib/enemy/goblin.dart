import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';

class Goblin extends Enemy {
  final Position initPosition;
  double attack = 25;
  bool _seePlayerClose = false;

  Goblin({
    @required this.initPosition,
  }) : super(
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
          width: 25,
          height: 25,
          speed: 1.5,
          life: 100,
        );

  @override
  void update(double dt) {
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

    super.update(dt);
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
          position: positionInWorld),
    );
    remove();
    super.die();
  }

  void execAttackRange() {
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
        width: 25,
        height: 25,
        damage: attack,
        speed: speed * 1.5,
        execute: () {
          print('attack range');
        },
        destroy: () {
          print('destroy attack range');
        });
  }

  void execAttack() {
    this.simpleAttackMelee(
        heightArea: 20,
        widthArea: 20,
        damage: attack / 2,
        interval: 300,
        withPush: true,
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
        execute: () {
          print('attack meele');
        });
  }

  @override
  void receiveDamage(double damage) {
    this.showDamage(damage);
    super.receiveDamage(damage);
  }
}
