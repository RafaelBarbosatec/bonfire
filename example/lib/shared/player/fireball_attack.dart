import 'package:bonfire/bonfire.dart';
import 'package:example/shared/player/knight.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

mixin FireballAttack on SimplePlayer {
  bool executingRangeAttack = false;
  double radAngleRangeAttack = 0;

  Rect? rectDirectionAttack;
  Sprite? spriteDirectionAttack;

  Knight get knight => this as Knight;

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == PlayerAttackType.attackRange) {
      if (event.event == ActionEvent.MOVE) {
        executingRangeAttack = true;
        radAngleRangeAttack = event.radAngle;
      }
      if (event.event == ActionEvent.UP) {
        executingRangeAttack = false;
      }
    }
    super.onJoystickAction(event);
  }

  @override
  void update(double dt) {
    _executeRangeAttack(dt);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    _drawDirectionAttack(canvas);
    super.render(canvas);
  }

  @override
  Future<void> onLoad() async {
    spriteDirectionAttack = await Sprite.load('direction_attack.png');
    return super.onLoad();
  }

  void _drawDirectionAttack(Canvas c) {
    if (executingRangeAttack) {
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
          radAngleRangeAttack,
          rectDirectionAttack!,
          spriteDirectionAttack!,
        );
      }
    }
  }

  void _executeRangeAttack(double dt) {
    if (!executingRangeAttack || knight.barLifeController.stamina < 10) {
      return;
    }
    if (checkInterval('ATTACK_RANGE', 150, dt)) {
      knight.decrementStamina(10);
      execRangeAttack(radAngleRangeAttack, knight.attack / 2);
    }
  }

  void execRangeAttack(double angle, double damage) {
    simpleAttackRangeByAngle(
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
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
}
