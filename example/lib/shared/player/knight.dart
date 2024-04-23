import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/interface/bar_life_controller.dart';
import 'package:example/shared/player/fireball_attack.dart';
import 'package:example/shared/player/player_dialog.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:example/shared/util/player_sprite_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PlayerAttackType {
  attackMelee,
  attackRange,
}

class Knight extends SimplePlayer
    with Lighting, BlockMovementCollision, FireballAttack {
  double attack = 20;
  bool canShowEmote = true;
  bool showedDialog = false;

  late BarLifeController barLifeController;

  Knight(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          size: Vector2.all(DungeonMap.tileSize),
          position: position,
          speed: DungeonMap.tileSize * 1.5,
          life: 200,
        ) {
    setupMovementByJoystick(intensityEnabled: true);
    setupLighting(
      LightingConfig(
        radius: width * 1.5,
        color: Colors.transparent,
      ),
    );
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    if (hasGameRef && gameRef.sceneBuilderStatus.isRunning) {
      return;
    }
    super.onJoystickChangeDirectional(event);
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (hasGameRef && gameRef.sceneBuilderStatus.isRunning || isDead) {
      return;
    }
    if (event.event == ActionEvent.DOWN) {
      if (event.id == LogicalKeyboardKey.space ||
          event.id == PlayerAttackType.attackMelee) {
        if (barLifeController.stamina >= 15) {
          decrementStamina(15);
          execMeleeAttack(attack);
        }
      }
    }

    super.onJoystickAction(event);
  }

  @override
  void onDie() {
    barLifeController.life = 0.0;
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: position,
        size: Vector2.all(DungeonMap.tileSize),
      ),
    );
    super.onDie();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _checkViewEnemy(dt);
    _updateLifeAndStamina(dt);
  }

  @override
  void onRemoveLife(double life) {
    showDamage(
      life,
      config: TextStyle(
        fontSize: width / 3,
        color: Colors.red,
      ),
    );
    super.onRemoveLife(life);
  }

  void execShowEmote() {
    add(
      AnimatedGameObject(
        position: Vector2(width / 4, 0),
        animation: CommonSpriteSheet.emote,
        size: Vector2.all(width / 2),
        loop: false,
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size / 2, position: size / 4));
    return super.onLoad();
  }

  @override
  void onMount() {
    barLifeController = BarLifeController();
    barLifeController.configure(maxLife: maxLife, maxStamina: 100);
    super.onMount();
  }

  void decrementStamina(int i) {
    barLifeController.decrementStamina(i);
  }

  void _updateLifeAndStamina(double dt) {
    barLifeController.updateLife(life);
    if (barLifeController.stamina >= 100) {
      return;
    }
    if (checkInterval('INCREMENT_STAMINA', 100, dt)) {
      barLifeController.increaseStamina(2);
    }
  }

  void _checkViewEnemy(double dt) {
    if (checkInterval('seeEnemy', 250, dt)) {
      seeEnemy(
        radiusVision: width * 4,
        notObserved: () => canShowEmote = true,
        observed: (enemies) => _handleObserveEnemy(enemies.first),
      );
    }
  }

  void _handleObserveEnemy(Enemy enemy) {
    if (canShowEmote) {
      canShowEmote = false;
      execShowEmote();
    }
    if (!showedDialog) {
      showedDialog = true;
      double lastZoom = gameRef.camera.zoom;
      stopMove();
      PlayerDialog.execShowTalk(
        gameRef,
        enemy,
        () {
          if (!isDead) {
            gameRef.camera.moveToPlayerAnimated(
              effectController: EffectController(duration: 1),
              zoom: lastZoom,
            );
          }
        },
      );
    }
  }

  void execMeleeAttack(double attack) {
    simpleAttackMelee(
      damage: attack,
      animationRight: CommonSpriteSheet.whiteAttackEffectRight,
      size: Vector2.all(DungeonMap.tileSize),
    );
  }
}
