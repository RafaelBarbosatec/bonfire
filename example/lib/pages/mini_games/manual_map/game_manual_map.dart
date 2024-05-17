import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/pages/mini_games/manual_map/game_manual_controller.dart';
import 'package:example/shared/interface/knight_interface.dart';
import 'package:example/shared/player/knight.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameManualMap extends StatelessWidget {
  const GameManualMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return BonfireWidget(
        playerControllers: [
          Joystick(
            directional: JoystickDirectional(
              spriteBackgroundDirectional:
                  Sprite.load('joystick_background.png'),
              spriteKnobDirectional: Sprite.load('joystick_knob.png'),
              size: 100,
              isFixed: false,
            ),
            actions: [
              JoystickAction(
                actionId: PlayerAttackType.attackMelee,
                sprite: Sprite.load('joystick_attack.png'),
                size: 80,
                margin: const EdgeInsets.only(bottom: 50, right: 50),
              ),
              JoystickAction(
                actionId: PlayerAttackType.attackRange,
                sprite: Sprite.load('joystick_attack_range.png'),
                spriteBackgroundDirection:
                    Sprite.load('joystick_background.png'),
                size: 50,
                enableDirection: true,
                margin: const EdgeInsets.only(bottom: 50, right: 160),
              )
            ],
          ),
          Keyboard(
            config: KeyboardConfig(
              acceptedKeys: [
                LogicalKeyboardKey.space,
              ],
            ),
          )
        ],
        player: Knight(
          Vector2((4 * DungeonMap.tileSize), (6 * DungeonMap.tileSize)),
        ),
        components: [
          ...DungeonMap.enemies(),
          ...DungeonMap.decorations(),
          GameManualController(),
        ],
        cameraConfig: CameraConfig(
          zoom: getZoomFromMaxVisibleTile(context, DungeonMap.tileSize, 20),
        ),
        interface: KnightInterface(),
        map: DungeonMap.map(),
        backgroundColor: Colors.blueGrey[900]!,
        lightingColorGame: Colors.black.withOpacity(0.75),
      );
    });
  }
}
