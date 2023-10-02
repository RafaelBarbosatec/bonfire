import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/util/player_sprite_sheet.dart';
import 'package:example/shared/util/wizard_sprite_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Wizard extends SimpleNpc with BlockMovementCollision, TapGesture {
  double lastZoom = 1.0;
  Wizard(Vector2 position)
      : super(
          animation: WizardSpriteSheet.simpleDirectionAnimation,
          position: position,
          size: Vector2.all(DungeonMap.tileSize * 0.8),
          speed: DungeonMap.tileSize * 1.6,
        );

  void execShowTalk(GameComponent first) {
    lastZoom = gameRef.camera.zoom;
    gameRef.camera.moveToTargetAnimated(
      target: first,
      effectController: EffectController(
        duration: 0.5,
        curve: Curves.easeInOut,
      ),
      zoom: 2,
      onComplete: _showTalk,
    );
  }

  @override
  void onTap() {
    execShowTalk(this);
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
          DungeonMap.tileSize * 0.4,
        ),
      ),
    );
    return super.onLoad();
  }

  void _showTalk() {
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: [
            const TextSpan(
              text:
                  ' Would you tell me, please ...  which way I ought to go from here? ',
            )
          ],
          person: SizedBox(
            width: 100,
            height: 100,
            child: PlayerSpriteSheet.idleRight.asWidget(),
          ),
        ),
        Say(
          text: [
            const TextSpan(
              text: 'That depends a good deal on where you want to get to.',
            ),
          ],
          person: SizedBox(
            width: 100,
            height: 100,
            child: WizardSpriteSheet.idle.asWidget(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
        Say(
          text: [
            const TextSpan(
              text: ' I don\'t much care where. ',
            ),
          ],
          person: SizedBox(
            width: 100,
            height: 100,
            child: PlayerSpriteSheet.idleRight.asWidget(),
          ),
        ),
        Say(
          text: [
            const TextSpan(
              text: 'Then it doesn\'t much matter which way you go.',
            ),
          ],
          person: SizedBox(
            width: 100,
            height: 100,
            child: WizardSpriteSheet.idle.asWidget(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
      ],
      onClose: () {
        gameRef.camera.moveToPlayerAnimated(
          effectController: EffectController(
            duration: 0.5,
            curve: Curves.easeInOut,
          ),
          zoom: lastZoom,
        );
      },
      onFinish: () {},
      logicalKeyboardKeysToNext: [
        LogicalKeyboardKey.space,
        LogicalKeyboardKey.enter
      ],
    );
  }
}
