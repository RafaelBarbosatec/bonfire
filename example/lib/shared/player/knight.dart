import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/interface/bar_life_controller.dart';
import 'package:example/shared/player/player_dialog.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:example/shared/util/player_sprite_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PlayerAttackType {
  attackMelee,
  attackRange,
}

class Knight extends SimplePlayer with Lighting, BlockMovementCollision {
  double attack = 20;
  bool canShowEmote = true;
  bool showedDialog = false;
  bool executingRangeAttack = false;
  double radAngleRangeAttack = 0;

  double angleRadAttack = 0.0;
  Rect? rectDirectionAttack;
  Sprite? spriteDirectionAttack;
  bool showBgRangeAttack = false;

  late BarLifeController barLifeController;

  Knight(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          size: Vector2.all(DungeonMap.tileSize),
          position: position,
          speed: DungeonMap.tileSize * 1.5,
          life: 200,
        ) {
    setupMovementByJoystick(intencityEnabled: true);
    setupLighting(
      LightingConfig(
        radius: width * 1.5,
        blurBorder: width * 1.5,
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
          _decrementStamina(15);
          execMeleeAttack(attack);
        }
      }
    }

    if (event.id == PlayerAttackType.attackRange) {
      if (event.event == ActionEvent.MOVE) {
        executingRangeAttack = true;
        radAngleRangeAttack = event.radAngle;
      }
      if (event.event == ActionEvent.UP) {
        executingRangeAttack = false;
      }
      execEnableBGRangeAttack(executingRangeAttack, event.radAngle);
    }
    super.onJoystickAction(event);
  }

  @override
  void die() {
    barLifeController.life = 0.0;
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: position,
        size: Vector2.all(DungeonMap.tileSize),
      ),
    );
    super.die();
  }

  void execMeleeAttack(double attack) {
    simpleAttackMelee(
      damage: attack,
      animationRight: CommonSpriteSheet.whiteAttackEffectRight,
      size: Vector2.all(DungeonMap.tileSize),
    );
  }

  void execRangeAttack(double angle, double damage) {
    simpleAttackRangeByAngle(
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
      animation: CommonSpriteSheet.fireBallRight,
      animationDestroy: CommonSpriteSheet.explosionAnimation,
      angle: angle,
      size: Vector2.all(width * 0.7),
      damage: damage,
      speed: speed * 3,
      collision: RectangleHitbox(
        size: Vector2(width / 3, width / 3),
        position: Vector2(width * 0.1, 0),
      ),
      lightingConfig: LightingConfig(
        radius: width / 2,
        blurBorder: width,
        color: Colors.orange.withOpacity(0.3),
      ),
    );
  }

  @override
  void update(double dt) {
    _checkViewEnemy(dt);
    _executeRangeAttack(dt);
    _updateLifeAndStamina(dt);

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    _drawDirectionAttack(canvas);
    super.render(canvas);
  }

  @override
  void receiveDamage(AttackFromEnum attacker, double damage, identify) {
    showDamage(
      damage,
      config: TextStyle(
        fontSize: width / 3,
        color: Colors.red,
      ),
    );
    super.receiveDamage(attacker, damage, identify);
  }

  void execShowEmote() {
    if (hasGameRef) {
      add(
        AnimatedGameObject(
          position: Vector2(width / 4, 0),
          animation: CommonSpriteSheet.emote,
          size: Vector2.all(width / 2),
          loop: false,
        ),
      );
    }
  }

  void _drawDirectionAttack(Canvas c) {
    if (showBgRangeAttack) {
      double radius = height;
      rectDirectionAttack = Rect.fromLTWH(
        -radius / 2,
        -radius / 2,
        radius * 2,
        radius * 2,
      );

      if (rectDirectionAttack != null && spriteDirectionAttack != null) {
        renderSpriteByRadAngle(
          c,
          angleRadAttack,
          rectDirectionAttack!,
          spriteDirectionAttack!,
        );
      }
    }
  }

  @override
  Future<void> onLoad() async {
    add(
      RectangleHitbox(
        size: size / 2,
        position: size / 4,
      ),
    );
    spriteDirectionAttack = await Sprite.load('direction_attack.png');
    return super.onLoad();
  }

  @override
  void onMount() {
    barLifeController = BarLifeController();
    barLifeController.configure(maxLife: maxLife, maxStamina: 100);
    super.onMount();
  }

  void execEnableBGRangeAttack(bool enabled, double angle) {
    showBgRangeAttack = enabled;
    angleRadAttack = angle;
  }

  void _decrementStamina(int i) {
    barLifeController.stamina -= i;
    if (barLifeController.stamina < 0) {
      barLifeController.stamina = 0;
    }
  }

  void _updateLifeAndStamina(double dt) {
    barLifeController.updateLife(life);
    if (barLifeController.stamina >= 100) {
      return;
    }
    if (checkInterval('INCREMENT_STAMINA', 100, dt) == true) {
      barLifeController.increaseStamina(2);
    }
  }

  void _checkViewEnemy(double dt) {
    bool seeEnemyInterval = checkInterval('seeEnemy', 250, dt);
    if (seeEnemyInterval) {
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

  void _executeRangeAttack(double dt) {
    if (!executingRangeAttack || barLifeController.stamina < 10) {
      return;
    }
    bool execRangeAttackInterval = checkInterval(
      'ATTACK_RANGE',
      150,
      dt,
    );
    if (execRangeAttackInterval) {
      _decrementStamina(10);
      execRangeAttack(radAngleRangeAttack, attack / 2);
    }
  }
}
