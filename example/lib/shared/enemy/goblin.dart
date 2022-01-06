import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:example/shared/util/enemy_sprite_sheet.dart';
import 'package:flutter/material.dart';

class Goblin extends SimpleEnemy
    with
        ObjectCollision,
        JoystickListener,
        MovementByJoystick,
        AutomaticRandomMovement {
  double attack = 20;
  bool _seePlayerToAttackMelee = false;
  bool enableBehaviors = true;

  Goblin(Vector2 position)
      : super(
          animation: EnemySpriteSheet.simpleDirectionAnimation,
          position: position,
          size: Vector2.all(DungeonMap.tileSize * 0.8),
          speed: DungeonMap.tileSize * 1.6,
          life: 100,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(
              DungeonMap.tileSize * 0.4,
              DungeonMap.tileSize * 0.4,
            ),
            align: Vector2(
              DungeonMap.tileSize * 0.2,
              DungeonMap.tileSize * 0.2,
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
    if (!enableBehaviors) return;

    _seePlayerToAttackMelee = false;

    this.seeAndMoveToPlayer(
      closePlayer: (player) {
        execAttack();
      },
      observed: () {
        _seePlayerToAttackMelee = true;
      },
      radiusVision: DungeonMap.tileSize * 1.5,
    );

    if (!_seePlayerToAttackMelee) {
      this.seeAndMoveToAttackRange(
        minDistanceFromPlayer: DungeonMap.tileSize * 2,
        positioned: (p) {
          execAttackRange();
        },
        radiusVision: DungeonMap.tileSize * 3,
        notObserved: () {
          runRandomMovement(
            dt,
            speed: speed / 2,
            maxDistance: (DungeonMap.tileSize * 3).toInt(),
          );
        },
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    this.drawDefaultLifeBar(
      canvas,
      borderRadius: BorderRadius.circular(5),
      borderWidth: 2,
    );
  }

  @override
  void die() {
    gameRef.add(
      AnimatedObjectOnce(
          animation: CommonSpriteSheet.smokeExplosion,
          position: position,
          size: Vector2.all(DungeonMap.tileSize)),
    );
    removeFromParent();
    super.die();
  }

  void execAttackRange() {
    if (gameRef.player != null && gameRef.player?.isDead == true) return;
    this.simpleAttackRange(
      animationRight: CommonSpriteSheet.fireBallRight,
      animationLeft: CommonSpriteSheet.fireBallLeft,
      animationUp: CommonSpriteSheet.fireBallTop,
      animationDown: CommonSpriteSheet.fireBallBottom,
      animationDestroy: CommonSpriteSheet.explosionAnimation,
      id: 35,
      size: Vector2.all(width * 0.9),
      damage: attack,
      speed: DungeonMap.tileSize * 3,
      collision: CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2.all(width / 2),
            align: Vector2(width * 0.25, width * 0.25),
          ),
        ],
      ),
      lightingConfig: LightingConfig(
        radius: width / 2,
        blurBorder: width,
        color: Colors.orange.withOpacity(0.3),
      ),
    );
  }

  void execAttack() {
    if (gameRef.player != null && gameRef.player?.isDead == true) return;
    this.simpleAttackMelee(
      size: Vector2.all(width),
      damage: attack / 2,
      interval: 400,
      sizePush: DungeonMap.tileSize / 2,
      animationDown: CommonSpriteSheet.blackAttackEffectBottom,
      animationLeft: CommonSpriteSheet.blackAttackEffectLeft,
      animationRight: CommonSpriteSheet.blackAttackEffectRight,
      animationUp: CommonSpriteSheet.blackAttackEffectTop,
    );
  }

  @override
  void receiveDamage(double damage, dynamic from) {
    this.showDamage(
      damage,
      config: TextStyle(
        fontSize: width / 3,
        color: Colors.white,
      ),
    );
    super.receiveDamage(damage, from);
  }

  @override
  void joystickAction(JoystickActionEvent event) {}

  @override
  void moveTo(Vector2 position) {}
}
