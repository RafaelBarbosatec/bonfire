import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Knight extends SimplePlayer with Lighting {
  final Position initPosition;
  double attack = 20;
  double stamina = 100;
  double initSpeed = DungeonMap.tileSize * 3;
  IntervalTick _timerStamina = IntervalTick(100);
  IntervalTick _timerAttackRange = IntervalTick(100);
  IntervalTick _timerSeeEnemy = IntervalTick(500);
  bool showObserveEnemy = false;
  bool showTalk = false;
  double angleRadAttack = 0.0;
  Rect rectDirectionAttack;
  Sprite spriteDirectionAttack;
  bool showDirection = false;
  FlameAnimation.Animation get fireBallAnimation =>
      FlameAnimation.Animation.sequenced(
        'player/fireball_top.png',
        3,
        textureWidth: 23,
        textureHeight: 23,
      );

  FlameAnimation.Animation get explosionAnimation =>
      FlameAnimation.Animation.sequenced(
        'player/explosion_fire.png',
        6,
        textureWidth: 32,
        textureHeight: 32,
      );

  Knight(this.initPosition)
      : super(
          newAnimation: SimplePlayerAnimation(
            idleLeft: FlameAnimation.Animation.sequenced(
              "player/knight_idle_left.png",
              6,
              textureWidth: 16,
              textureHeight: 16,
            ),
            idleRight: FlameAnimation.Animation.sequenced(
              "player/knight_idle.png",
              6,
              textureWidth: 16,
              textureHeight: 16,
            ),
            runRight: FlameAnimation.Animation.sequenced(
              "player/knight_run.png",
              6,
              textureWidth: 16,
              textureHeight: 16,
            ),
            runLeft: FlameAnimation.Animation.sequenced(
              "player/knight_run_left.png",
              6,
              textureWidth: 16,
              textureHeight: 16,
            ),
          ),
          width: DungeonMap.tileSize,
          height: DungeonMap.tileSize,
          initPosition: initPosition,
          life: 200,
          speed: DungeonMap.tileSize * 3,
          collision: Collision(
            height: DungeonMap.tileSize / 2,
            width: DungeonMap.tileSize / 1.8,
            align: Offset(DungeonMap.tileSize / 3.5, DungeonMap.tileSize / 2),
          ),
        ) {
    spriteDirectionAttack = Sprite('direction_attack.png');
    lightingConfig = LightingConfig(
      gameComponent: this,
      radius: width * 1.5,
      blurBorder: width * 1.5,
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

    if (gameRef.joystickController.keyboardEnable) {
      if (event.id == LogicalKeyboardKey.space.keyId) {
        actionAttack();
      }
    }

    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == 1) {
      if (event.event == ActionEvent.MOVE) {
        showDirection = true;
        angleRadAttack = event.radAngle;
        if (_timerAttackRange.update(dtUpdate)) actionAttackRange();
      }
      if (event.event == ActionEvent.UP) {
        showDirection = false;
        actionAttackRange();
      }
    }

    super.joystickAction(event);
  }

  @override
  void die() {
    remove();
    gameRef.addGameComponent(
      GameDecoration(
        initPosition: Position(
          position.left,
          position.top,
        ),
        height: DungeonMap.tileSize,
        width: DungeonMap.tileSize,
        sprite: Sprite('player/crypt.png'),
      ),
    );
    super.die();
  }

  void actionAttack() {
    if (stamina < 15) return;

    decrementStamina(15);
    this.simpleAttackMelee(
      damage: attack,
      animationBottom: FlameAnimation.Animation.sequenced(
        'player/atack_effect_bottom.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
      animationLeft: FlameAnimation.Animation.sequenced(
        'player/atack_effect_left.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
      animationRight: FlameAnimation.Animation.sequenced(
        'player/atack_effect_right.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
      animationTop: FlameAnimation.Animation.sequenced(
        'player/atack_effect_top.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
      heightArea: DungeonMap.tileSize,
      widthArea: DungeonMap.tileSize,
    );

    newAnimation.playOnce(explosionAnimation);
  }

  void actionAttackRange() {
    if (stamina < 10) return;

    this.simpleAttackRangeByAngle(
      animationTop: fireBallAnimation,
      animationDestroy: explosionAnimation,
      radAngleDirection: angleRadAttack,
      width: width * 0.7,
      height: width * 0.7,
      damage: 10,
      speed: initSpeed * 2,
      collision: Collision(
        width: width / 2,
        height: width / 2,
        align: Offset(width * 0.1, 0),
      ),
      lightingConfig: LightingConfig(
        gameComponent: this,
        radius: width * 0.5,
        blurBorder: width,
      ),
    );
  }

  @override
  void update(double dt) {
    if (this.isDead || gameRef?.size == null) return;
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
  void receiveDamage(double damage, int from) {
    this.showDamage(damage,
        config: TextConfig(
          fontSize: width / 3,
          color: Colors.red,
        ));
    super.receiveDamage(damage, from);
  }

  void showEmote() {
    gameRef.add(
      AnimatedFollowerObject(
        animation: FlameAnimation.Animation.sequenced(
          'player/emote_exclamacao.png',
          8,
          textureWidth: 32,
          textureHeight: 32,
        ),
        target: this,
        width: width / 2,
        height: width / 2,
        positionFromTarget: Position(18, -6),
      ),
    );
  }

  void _showTalk(Enemy first) {
    gameRef.gameCamera.moveToTargetAnimated(first, zoom: 2, finish: () {
      TalkDialog.show(gameRef.context, [
        Say(
          "Look at this! It seems that I'm not alone here ...",
          Container(
            width: 50,
            height: 50,
            child: AnimationWidget(
              animation: newAnimation.current,
              playing: true,
            ),
          ),
        ),
      ], finish: () {
        gameRef.gameCamera.moveToPlayerAnimated();
      });
    });
  }

  void _drawDirectionAttack(Canvas c) {
    if (showDirection) {
      double radius = position.height;
      rectDirectionAttack = Rect.fromLTWH(position.center.dx - radius,
          position.center.dy - radius, radius * 2, radius * 2);
      renderSpriteByRadAngle(
        c,
        angleRadAttack,
        rectDirectionAttack,
        spriteDirectionAttack,
      );
    }
  }
}
