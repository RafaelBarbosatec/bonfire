import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class Knight extends Player {
  final Position initPosition;
  double attack = 20;
  double stamina = 100;
  Timer _timerStamina;
  bool showObserveEnemy = false;
  bool showTalk = false;

  Knight({
    this.initPosition,
  }) : super(
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
            width: 32,
            height: 32,
            initPosition: initPosition,
            life: 200,
            speed: 2.5,
            collision: Collision(height: 16, width: 16));

  @override
  void joystickAction(int action) {
    if (isDead) return;

    if (action == 0) {
      actionAttack();
    }

    if (action == 1) {
      actionAttackRange();
    }

    super.joystickAction(action);
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
        spriteImg: 'player/crypt.png',
      ),
    );
    super.die();
  }

  void actionAttack() {
    if (stamina < 15) return;

    decrementStamina(15);
    this.simpleAttackMelee(
      damage: attack,
      attackEffectBottomAnim: FlameAnimation.Animation.sequenced(
        'player/atack_effect_bottom.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
      attackEffectLeftAnim: FlameAnimation.Animation.sequenced(
        'player/atack_effect_left.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
      attackEffectRightAnim: FlameAnimation.Animation.sequenced(
        'player/atack_effect_right.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
      attackEffectTopAnim: FlameAnimation.Animation.sequenced(
        'player/atack_effect_top.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      ),
      widthArea: 16,
      heightArea: 16,
    );
  }

  void actionAttackRange() {
    if (stamina < 10) return;

    decrementStamina(10);
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
      damage: 10,
      speed: speed * 1.5,
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
        _showEmote();
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
    super.render(c);
  }

  void _verifyStamina() {
    if (_timerStamina == null) {
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
  void receiveDamage(double damage) {
    this.showDamage(damage);
    super.receiveDamage(damage);
  }

  void _showEmote() {
    gameRef.add(
      AnimatedFollowerObject(
        animation: FlameAnimation.Animation.sequenced(
          'player/emote_exclamacao.png',
          8,
          textureWidth: 32,
          textureHeight: 32,
        ),
        target: this,
        width: 16,
        height: 16,
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
