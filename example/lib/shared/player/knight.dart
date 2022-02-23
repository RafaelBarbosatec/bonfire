import 'dart:io';

import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/shared/enemy/goblin.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:example/shared/util/enemy_sprite_sheet.dart';
import 'package:example/shared/util/player_sprite_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'knight_controller.dart';
import 'knight_events.dart';

enum PlayerAttackType { AttackMelee, AttackRange }

class Knight extends SimplePlayer
    with
        Lighting,
        ObjectCollision,
        MouseGesture,
        WithController<KnightController> {
  static final double maxSpeed = DungeonMap.tileSize * 3;
  double attack = 20;
  double stamina = 100;
  double angleRadAttack = 0.0;
  Rect? rectDirectionAttack;
  Sprite? spriteDirectionAttack;
  bool execAttackRange = false;
  bool canShowEmoteFromHover = true;
  Goblin? enemyControlled;

  Rect _rectHover = Rect.fromLTWH(
    0,
    0,
    DungeonMap.tileSize,
    DungeonMap.tileSize,
  );
  Paint paintHover = new Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

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

    _enableMouseGesture();

    on((ExecMeleeAttack action) => _execMeleeAttack());
    on((ExecRangeAttack action) {
      execAttackRange = action.enabled;
      angleRadAttack = action.radAngle;
    });
    on((ExecDie action) => _execDie());
    on((ExecShowEmote action) => showEmote());
    on((ExecShowTalk action) => _showTalk(action.target));
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    this.speed = maxSpeed * event.intensity;
    super.joystickChangeDirectional(event);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (isDead) return;
    sendEvent(OnInteractJoystick(event.id, event.event, event.radAngle));
    super.joystickAction(event);
  }

  @override
  void die() {
    sendEvent(OnDie());
    super.die();
  }

  void _execMeleeAttack() {
    if (stamina < 15) return;

    decrementStamina(15);
    this.simpleAttackMelee(
      damage: attack,
      animationDown: CommonSpriteSheet.whiteAttackEffectBottom,
      animationLeft: CommonSpriteSheet.whiteAttackEffectLeft,
      animationRight: CommonSpriteSheet.whiteAttackEffectRight,
      animationUp: CommonSpriteSheet.whiteAttackEffectTop,
      size: Vector2.all(DungeonMap.tileSize),
    );
  }

  void _actionAttackRange() {
    if (stamina < 10) return;

    this.simpleAttackRangeByAngle(
      animation: CommonSpriteSheet.fireBallRight,
      animationDestroy: CommonSpriteSheet.explosionAnimation,
      angle: angleRadAttack,
      size: Vector2.all(width * 0.7),
      damage: 10,
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
    if (this.isDead) return;
    _verifyStamina(dt);

    if (checkInterval('seeEnemy', 250, dt)) {
      this.seeEnemy(
        radiusVision: width * 4,
        notObserved: () => sendEvent(OnNotObserveEnemy()),
        observed: (enemies) => sendEvent(OnObserveEnemy(enemies.first)),
      );
    }

    if (execAttackRange && checkInterval('ATTACK_RANGE', 150, dt)) {
      _actionAttackRange();
    }
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    _drawDirectionAttack(c);
    if (_rectHover.left != 0 || _rectHover.top != 0) {
      c.drawRect(_rectHover, paintHover);
    }
  }

  void _verifyStamina(double dt) {
    if (stamina < 100 && checkInterval('INCREMENT_STAMINA', 100, dt)) {
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
      config: TextStyle(
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
        size: Vector2.all(width / 2),
        positionFromTarget: Vector2(
          18,
          -6,
        ),
      ),
    );
  }

  void changeControllerToVisibleEnemy() {
    if (hasGameRef && !gameRef.camera.isMoving) {
      if (enemyControlled == null) {
        final v = gameRef
            .visibleEnemies()
            .where((element) => element is Goblin)
            .cast<Goblin>();
        if (v.isNotEmpty) {
          enemyControlled = v.first;
          enemyControlled?.enableBehaviors = false;
          gameRef.addJoystickObserver(
            enemyControlled!,
            cleanObservers: true,
            moveCameraToTarget: true,
          );
        }
      } else {
        gameRef.addJoystickObserver(
          this,
          cleanObservers: true,
          moveCameraToTarget: true,
        );
        enemyControlled?.enableBehaviors = true;
        enemyControlled = null;
      }
    }
  }

  void _showTalk(GameComponent first) {
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
    if (execAttackRange) {
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
    await super.onLoad();
    spriteDirectionAttack = await Sprite.load('direction_attack.png');
  }

  @override
  void onHoverEnter(int pointer, Vector2 position) {
    if (canShowEmoteFromHover) {
      canShowEmoteFromHover = false;
      showEmote();
    }
  }

  @override
  void onHoverExit(int pointer, Vector2 position) {
    canShowEmoteFromHover = true;
  }

  @override
  void onHoverScreen(int pointer, Vector2 position) {
    Vector2 p = gameRef.screenToWorld(position);
    double left = p.x - (p.x % DungeonMap.tileSize);
    double top = p.y - (p.y % DungeonMap.tileSize);
    _rectHover = Rect.fromLTWH(left, top, _rectHover.width, _rectHover.height);
  }

  @override
  void onScroll(int pointer, Vector2 position, Vector2 scrollDelta) {
    print(scrollDelta);
    // do anything when use scroll of the mouse in your component
  }

  @override
  void onMouseCancel() {
    print('onMouseCancel');
  }

  @override
  void onMouseTapLeft() {
    print('onMouseTapLeft');
  }

  @override
  void onMouseTapRight() {
    print('onMouseTapRight');
  }

  @override
  void onMouseTapMiddle() {
    print('onMouseTapMiddle');
  }

  void _enableMouseGesture() {
    if (!kIsWeb) {
      enableMouseGesture =
          (Platform.isAndroid || Platform.isIOS) ? false : true;
    }
  }

  void _execDie() {
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: position,
        size: Vector2.all(DungeonMap.tileSize),
      ),
    );
  }
}
