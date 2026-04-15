import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:example/shared/util/enemy_sprite_sheet.dart';
import 'package:flutter/material.dart';

class Goblin extends SimpleEnemy
    with
        BlockMovementCollision,
        PlayerControllerListener,
        MovementByJoystick,
        RandomMovement,
        UseLifeBar,
        UseBehavior {
  double attack = 20;
  bool enableBehaviors = true;
  Goblin(Vector2 position)
      : super(
          animation: EnemySpriteSheet.simpleDirectionAnimation,
          position: position,
          size: Vector2.all(DungeonMap.tileSize * 0.8),
          speed: DungeonMap.tileSize,
          life: 100,
        ) {
    setupLifeBar(
      borderRadius: BorderRadius.circular(2),
      borderWidth: 2,
    );
  }

  @override
  List<Behavior> get behaviors => [
        BCondition(
          condition: (_, __, game) {
            return !game.sceneBuilderStatus.isRunning && enableBehaviors;
          },
          doBehavior: BCondition(
            condition: (_, __, game) {
              return game.player != null && game.player?.isDead == false;
            },
            doBehavior: BSeeAndMoveToTarget(
              target: gameRef.player!,
              radiusVision: DungeonMap.tileSize,
              onClose: (_, __) => execAttack(attack),
              doElseBehavior: BSeeAndPositioned(
                radiusVision: DungeonMap.tileSize * 3,
                positioned: (_) => execAttackRange(attack),
                target: gameRef.player!,
                doElseBehavior: BRandomMovement(
                  speed: speed / 2,
                  maxDistance: (DungeonMap.tileSize * 3),
                ),
              ),
            ),
            doElseBehavior: BRandomMovement(
              speed: speed / 2,
              maxDistance: (DungeonMap.tileSize * 3),
            ),
          ),
        ),
      ];

  @override
  void onDie() {
    super.onDie();
    gameRef.add(
      AnimatedGameObject(
        animation: CommonSpriteSheet.smokeExplosion,
        position: position,
        size: Vector2.all(DungeonMap.tileSize),
        loop: false,
      ),
    );
    removeFromParent();
  }

  void execAttackRange(double damage) {
    if (gameRef.player != null && gameRef.player?.isDead == true) return;
    simpleAttackRange(
      animation: CommonSpriteSheet.fireBallRight,
      animationDestroy: CommonSpriteSheet.explosionAnimation,
      id: 35,
      useAngle: true,
      size: Vector2.all(width * 0.9),
      damage: damage,
      speed: DungeonMap.tileSize * 3,
      collision: RectangleHitbox(
        size: Vector2.all(width / 2),
        position: Vector2(width * 0.25, width * 0.25),
      ),
      lightingConfig: LightingConfig(
        radius: width / 2,
        blurBorder: width,
        color: Colors.orange.withOpacity(0.3),
      ),
    );
  }

  void execAttack(double damage) {
    if (gameRef.player != null && gameRef.player?.isDead == true) return;
    simpleAttackMelee(
      size: Vector2.all(width),
      damage: damage / 2,
      interval: 400,
      sizePush: DungeonMap.tileSize / 2,
      animationRight: CommonSpriteSheet.blackAttackEffectRight,
    );
  }

  @override
  void removeLife(double life) {
    showDamage(
      life,
      config: TextStyle(
        fontSize: width / 3,
        color: Colors.white,
      ),
    );
    super.removeLife(life);
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          DungeonMap.tileSize * 0.4,
          DungeonMap.tileSize * 0.4,
        ),
        position: Vector2(
          DungeonMap.tileSize * 0.2,
          DungeonMap.tileSize * 0.2,
        ),
      ),
    );
    return super.onLoad();
  }
}
