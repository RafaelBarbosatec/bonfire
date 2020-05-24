import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Knight extends SimplePlayer with WithLighting {
  final Position initPosition;
  double attack = 20;
  double stamina = 100;
  double initSpeed = DungeonMap.tileSize * 3;
  Timer _timerStamina;
  bool showObserveEnemy = false;
  bool showTalk = false;
  double angleRadAttack = 0.0;
  Rect rectDirectionAttack;
  Sprite spriteDirectionAttack;
  bool showDirection = false;

  Knight(this.initPosition)
      : super(
          animIdleLeft: FlameAnimation.Animation.sequenced(
            "player/knight_idle_left.png",
            6,
            textureWidth: 16,
            textureHeight: 16,
          ),
          animIdleRight: FlameAnimation.Animation.sequenced(
            "player/knight_idle.png",
            6,
            textureWidth: 16,
            textureHeight: 16,
          ),
          animRunRight: FlameAnimation.Animation.sequenced(
            "player/knight_run.png",
            6,
            textureWidth: 16,
            textureHeight: 16,
          ),
          animRunLeft: FlameAnimation.Animation.sequenced(
            "player/knight_run_left.png",
            6,
            textureWidth: 16,
            textureHeight: 16,
          ),
          width: DungeonMap.tileSize,
          height: DungeonMap.tileSize,
          initPosition: initPosition,
          life: 200,
          speed: DungeonMap.tileSize * 3,
          collision: Collision(
              height: DungeonMap.tileSize / 2, width: DungeonMap.tileSize / 2),
        ) {
    spriteDirectionAttack = Sprite('direction_attack.png');
    lightingConfig = LightingConfig(
      gameComponent: this,
      color: Colors.yellow.withOpacity(0.1),
      radius: width * 1.5,
      blurBorder: width / 2,
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

    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == 1) {
      if (event.event == ActionEvent.MOVE) {
        showDirection = true;
        angleRadAttack = event.radAngle;
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
    gameRef.addDecoration(
      GameDecoration(
        initPosition: Position(
          positionInWorld.left,
          positionInWorld.top,
        ),
        height: 30,
        width: 30,
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
  }

  void actionAttackRange() {
    if (stamina < 10) return;

    decrementStamina(10);

    this.simpleAttackRangeByAngle(
      animationTop: FlameAnimation.Animation.sequenced(
        'player/fireball_top.png',
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
      radAngleDirection: angleRadAttack,
      width: width * 0.7,
      height: width * 0.7,
      damage: 10,
      speed: initSpeed * 2,
      lightingConfig: LightingConfig(
        gameComponent: this,
        color: Colors.orange.withOpacity(0.1),
        radius: 25,
        blurBorder: 15,
      ),
    );
  }

  @override
  void update(double dt) {
    if (this.isDead) return;
    _verifyStamina();
    this.seeEnemy(
      visionCells: 8,
      notObserved: () {
        showObserveEnemy = false;
      },
      observed: (enemies) {
        if (showObserveEnemy) return;
        showObserveEnemy = true;
        showEmote();
        if (!showTalk) {
          showTalk = true;
          _showTalk();
        }
      },
    );
    super.update(dt);
  }

  @override
  void render(Canvas c) {
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
    super.render(c);
  }

  void _verifyStamina() {
    if (_timerStamina == null && stamina < 100) {
      _timerStamina = Timer(Duration(milliseconds: 150), () {
        _timerStamina = null;
      });
    } else {
      return;
    }

    stamina += 2;
    if (stamina > 100) {
      stamina = 100;
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
    this.showDamage(damage);
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

  void _showTalk() {
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          "Look at this! It seems that I'm not alone here ...",
          Flame.util.animationAsWidget(
            Position(100, 100),
            animation,
          ),
        ),
      ],
    );
  }
}
