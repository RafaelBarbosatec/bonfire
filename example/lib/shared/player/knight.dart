import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/shared/interface/bar_life_controller.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:example/shared/util/enemy_sprite_sheet.dart';
import 'package:example/shared/util/player_sprite_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'knight_controller.dart';

enum PlayerAttackType { AttackMelee, AttackRange }

class Knight extends SimplePlayer
    with Lighting, ObjectCollision, UseStateController<KnightController> {
  static final double maxSpeed = DungeonMap.tileSize * 3;

  double angleRadAttack = 0.0;
  Rect? rectDirectionAttack;
  Sprite? spriteDirectionAttack;
  bool showBgRangeAttack = false;

  BarLifeController? barLifeController;

  Knight(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          size: Vector2.all(DungeonMap.tileSize),
          position: position,
          life: 200,
          speed: maxSpeed,
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
            size: Vector2(
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
    if (gameRef.sceneBuilderStatus.isRunning) {
      return;
    }
    this.speed = maxSpeed * event.intensity;
    super.joystickChangeDirectional(event);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (gameRef.sceneBuilderStatus.isRunning) {
      return;
    }
    if (hasController) {
      controller.handleJoystickAction(event);
    }
    super.joystickAction(event);
  }

  @override
  void die() {
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
    this.simpleAttackMelee(
      damage: attack,
      animationDown: CommonSpriteSheet.whiteAttackEffectBottom,
      animationLeft: CommonSpriteSheet.whiteAttackEffectLeft,
      animationRight: CommonSpriteSheet.whiteAttackEffectRight,
      animationUp: CommonSpriteSheet.whiteAttackEffectTop,
      size: Vector2.all(DungeonMap.tileSize),
    );
  }

  void execRangeAttack(double angle, double damage) {
    this.simpleAttackRangeByAngle(
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
      animation: CommonSpriteSheet.fireBallRight,
      animationDestroy: CommonSpriteSheet.explosionAnimation,
      angle: angle,
      size: Vector2.all(width * 0.7),
      damage: damage,
      speed: maxSpeed * 2,
      collision: CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(width / 3, width / 3),
            align: Vector2(width * 0.1, 0),
          ),
        ],
      ),
      marginFromOrigin: 20,
      lightingConfig: LightingConfig(
        radius: width / 2,
        blurBorder: width,
        color: Colors.orange.withOpacity(0.3),
      ),
    );
  }

  @override
  void update(double dt) {
    barLifeController?.life = life;
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    _drawDirectionAttack(c);
  }

  @override
  bool checkCanReceiveDamage(AttackFromEnum attacker, double damage, from) {
    bool shouldReceive = super.checkCanReceiveDamage(attacker, damage, from);
    if (shouldReceive && hasController) {
      controller.onReceiveDamage(damage);
    }
    return shouldReceive;
  }

  void execShowEmote() {
    if (hasGameRef) {
      gameRef.add(
        AnimatedFollowerObject(
          animation: CommonSpriteSheet.emote,
          target: this,
          size: Vector2.all(width / 2),
          positionFromTarget: Vector2(
            18,
            -6,
          ),
        ),
      );
    }
  }

  void execShowTalk(GameComponent first) {
    gameRef.camera.moveToTargetAnimated(
      first,
      zoom: 2,
      finish: () {
        TalkDialog.show(
          gameRef.context,
          [
            Say(
              text: [
                TextSpan(
                  text: 'Look at this! It seems that',
                ),
                TextSpan(
                  text: ' I\'m not alone ',
                  style: TextStyle(color: Colors.red),
                ),
                TextSpan(
                  text: 'here...',
                ),
              ],
              person: Container(
                width: 100,
                height: 100,
                child: PlayerSpriteSheet.idleRight.asWidget(),
              ),
            ),
            Say(
              text: [
                TextSpan(
                  text: 'Lok Tar Ogr!',
                ),
                TextSpan(
                  text: ' Lok Tar Ogr! ',
                  style: TextStyle(color: Colors.green),
                ),
                TextSpan(
                  text: ' Lok Tar Ogr! ',
                ),
                TextSpan(
                  text: 'Lok Tar Ogr!',
                  style: TextStyle(color: Colors.green),
                ),
              ],
              person: Container(
                width: 100,
                height: 100,
                child: EnemySpriteSheet.idleLeft.asWidget(),
              ),
              personSayDirection: PersonSayDirection.RIGHT,
            ),
          ],
          onClose: () {
            print('close talk');
            if (!this.isDead) {
              gameRef.camera.moveToPlayerAnimated(zoom: 1);
            }
          },
          onFinish: () {
            print('finish talk');
          },
          logicalKeyboardKeysToNext: [
            LogicalKeyboardKey.space,
            LogicalKeyboardKey.enter
          ],
        );
      },
    );
  }

  void _drawDirectionAttack(Canvas c) {
    if (showBgRangeAttack) {
      double radius = height;
      rectDirectionAttack = Rect.fromLTWH(
        rectCollision.center.dx - radius,
        rectCollision.center.dy - radius,
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
    spriteDirectionAttack = await Sprite.load('direction_attack.png');
    return super.onLoad();
  }

  @override
  void onMount() {
    barLifeController = BonfireInjector().get<BarLifeController>();
    barLifeController?.configure(maxLife: maxLife, maxStamina: 100);
    super.onMount();
  }

  void execEnableBGRangeAttack(bool enabled, double angle) {
    showBgRangeAttack = enabled;
    angleRadAttack = angle;
  }

  void execShowDamage(double damage) {
    this.showDamage(
      damage,
      config: TextStyle(
        fontSize: width / 3,
        color: Colors.red,
      ),
    );
  }

  void updateStamina(double stamina) {
    barLifeController?.stamina = stamina;
  }
}
