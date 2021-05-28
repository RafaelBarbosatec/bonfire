import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/util/common_sprite_sheet.dart';
import 'package:example/util/player_sprite_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PlayerAttackType { AttackMelee, AttackRange }

class Knight extends SimplePlayer with Lighting, ObjectCollision {
  double attack = 20;
  double stamina = 100;
  double initSpeed = DungeonMap.tileSize * 3;
  IntervalTick _timerStamina = IntervalTick(100);
  IntervalTick _timerAttackRange = IntervalTick(110);
  IntervalTick _timerSeeEnemy = IntervalTick(500);
  bool showObserveEnemy = false;
  bool showTalk = false;
  double angleRadAttack = 0.0;
  Rect? rectDirectionAttack;
  Sprite? spriteDirectionAttack;
  bool execAttackRange = false;

  Knight(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          width: DungeonMap.tileSize,
          height: DungeonMap.tileSize,
          position: position,
          life: 200,
          speed: DungeonMap.tileSize * 3,
        ) {
    setupLighting(
      LightingConfig(
        radius: width * 1.5,
        blurBorder: width * 1.5,
        color: Colors.transparent,
      ),
    );
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Size(
              DungeonMap.tileSize / 2,
              DungeonMap.tileSize / 2.2,
            ),
            align: Vector2(
              DungeonMap.tileSize / 3.5,
              DungeonMap.tileSize / 2,
            ),
          )
        ],
      ),
    );
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    this.speed = initSpeed * event.intensity;
    super.joystickChangeDirectional(event);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (isDead) return;

    if (event.id == LogicalKeyboardKey.space.keyId &&
        event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == PlayerAttackType.AttackMelee &&
        event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == PlayerAttackType.AttackRange) {
      if (event.event == ActionEvent.MOVE) {
        execAttackRange = true;
        angleRadAttack = event.radAngle;
      }
      if (event.event == ActionEvent.UP) {
        execAttackRange = false;
        actionAttackRange();
      }
    }

    super.joystickAction(event);
  }

  @override
  void die() {
    remove();
    gameRef.addGameComponent(
      GameDecoration.withSprite(
        Sprite.load('player/crypt.png'),
        position: Vector2(
          position.left,
          position.top,
        ),
        height: DungeonMap.tileSize,
        width: DungeonMap.tileSize,
      ),
    );
    super.die();
  }

  void actionAttack() {
    if (stamina < 15) return;

    decrementStamina(15);
    this.simpleAttackMelee(
      damage: attack,
      animationBottom: CommonSpriteSheet.whiteAttackEffectBottom,
      animationLeft: CommonSpriteSheet.whiteAttackEffectLeft,
      animationRight: CommonSpriteSheet.whiteAttackEffectRight,
      animationTop: CommonSpriteSheet.whiteAttackEffectTop,
      height: DungeonMap.tileSize,
      width: DungeonMap.tileSize,
    );
  }

  void actionAttackRange() {
    if (stamina < 10) return;

    this.simpleAttackRangeByAngle(
      animationTop: CommonSpriteSheet.fireBallTop,
      animationDestroy: CommonSpriteSheet.explosionAnimation,
      radAngleDirection: angleRadAttack,
      width: width * 0.7,
      height: width * 0.7,
      damage: 10,
      speed: initSpeed * 2,
      collision: CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Size(width / 3, width / 3),
            align: Vector2(width * 0.1, 0),
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

  @override
  void update(double dt) {
    if (this.isDead) return;
    _verifyStamina(dt);

    if (_timerSeeEnemy.update(dt) && !showObserveEnemy) {
      this.seeEnemy(
        radiusVision: width * 5,
        notObserved: () {
          showObserveEnemy = false;
        },
        observed: (enemies) {
          showObserveEnemy = true;
          showEmote();
          if (!showTalk) {
            showTalk = true;
            _showTalk(enemies.first);
          }
        },
      );
    }

    if (execAttackRange && _timerAttackRange.update(dt)) actionAttackRange();
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    _drawDirectionAttack(c);
    super.render(c);
  }

  void _verifyStamina(double dt) {
    if (_timerStamina.update(dt) && stamina < 100) {
      stamina += 2;
      if (stamina > 100) {
        stamina = 100;
      }
    }
  }

  void decrementStamina(int i) {
    stamina -= i;
    if (stamina < 0) {
      stamina = 0;
    }
  }

  @override
  void receiveDamage(double damage, dynamic from) {
    this.showDamage(
      damage,
      config: TextPaintConfig(
        fontSize: width / 3,
        color: Colors.red,
      ),
    );
    super.receiveDamage(damage, from);
  }

  void showEmote() {
    gameRef.add(
      AnimatedFollowerObject(
        animation: CommonSpriteSheet.emote,
        target: this,
        positionFromTarget: Rect.fromLTWH(
          18,
          -6,
          width / 2,
          height / 2,
        ).toVector2Rect(),
      ),
    );
  }

  void _showTalk(Enemy first) {
    gameRef.camera.moveToTargetAnimated(
      first,
      zoom: 2,
      finish: () {
        TalkDialog.show(
          gameRef.context,
          [
            Say(
              "Look at this! It seems that I'm not alone here ...",
              person: Container(
                width: 100,
                height: 100,
                child: FutureBuilder<SpriteAnimation>(
                  future: PlayerSpriteSheet.idleRight,
                  builder: (context, anim) {
                    if (!anim.hasData) return SizedBox.shrink();
                    return SpriteAnimationWidget(
                      animation: anim.data!,
                      playing: true,
                    );
                  },
                ),
              ),
            ),
          ],
          finish: () {
            gameRef.camera.moveToPlayerAnimated();
          },
          logicalKeyboardKeyToNext: LogicalKeyboardKey.space,
        );
      },
    );
  }

  void _drawDirectionAttack(Canvas c) {
    if (execAttackRange) {
      double radius = position.height;
      rectDirectionAttack = Rect.fromLTWH(
        position.center.dx - radius,
        position.center.dy - radius,
        radius * 2,
        radius * 2,
      );

      if (rectDirectionAttack != null && spriteDirectionAttack != null) {
        renderSpriteByRadAngle(
          c,
          angleRadAttack,
          rectDirectionAttack!.toVector2Rect(),
          spriteDirectionAttack!,
        );
      }
    }
  }

  @override
  Future<void> onLoad() async {
    spriteDirectionAttack = await Sprite.load('direction_attack.png');
    return super.onLoad();
  }
}
