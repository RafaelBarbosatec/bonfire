import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/shared/enemy/goblin.dart';
import 'package:example/shared/interface/knight_interface.dart';
import 'package:example/shared/player/knight.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameManualMap extends StatelessWidget implements GameListener {
  final GameController _controller = GameController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      DungeonMap.tileSize =
          max(constraints.maxHeight, constraints.maxWidth) / (kIsWeb ? 25 : 22);
      return BonfireWidget(
        joystick: Joystick(
          keyboardConfig: KeyboardConfig(
            acceptedKeys: [
              LogicalKeyboardKey.space,
            ],
          ),
          directional: JoystickDirectional(
            spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
            spriteKnobDirectional: Sprite.load('joystick_knob.png'),
            size: 100,
            isFixed: false,
          ),
          actions: [
            JoystickAction(
              actionId: PlayerAttackType.AttackMelee,
              sprite: Sprite.load('joystick_atack.png'),
              align: JoystickActionAlign.BOTTOM_RIGHT,
              size: 80,
              margin: EdgeInsets.only(bottom: 50, right: 50),
            ),
            JoystickAction(
              actionId: PlayerAttackType.AttackRange,
              sprite: Sprite.load('joystick_atack_range.png'),
              spriteBackgroundDirection: Sprite.load('joystick_background.png'),
              size: 50,
              enableDirection: true,
              margin: EdgeInsets.only(bottom: 50, right: 160),
            )
          ],
        ),
        // player: Knight(
        //   Vector2((4 * DungeonMap.tileSize), (6 * DungeonMap.tileSize)),
        // ),
        interface: KnightInterface(),
        map: NoiseMapGenerator.generate(
          noiseMatrix: noise2(
            100,
            100,
            // gain: 1,
            noiseType: NoiseType.PerlinFractal,
            cellularDistanceFunction: CellularDistanceFunction.Natural,
          ),
          builder: (prop) {
            Color? color = Colors.white;
            if (prop.height > -0.4) {
              color = Colors.green;
            }

            if (prop.height > -0.2) {
              color = Colors.orangeAccent;
            }

            if (prop.height > -0.1) {
              color = Colors.blue;
            }
            return TileModel(
              x: prop.position.x,
              y: prop.position.y,
              width: 5,
              height: 5,
              color: color,
            );
          },
        ),
        // map: DungeonMap.map(),
        // enemies: DungeonMap.enemies(),
        // decorations: DungeonMap.decorations(),
        background: BackgroundColorGame(Colors.blueGrey[900]!),
        gameController: _controller..addListener(this),
        // lightingColorGame: Colors.black.withOpacity(0.75),
      );
    });
  }

  @override
  void updateGame() {}

  @override
  void changeCountLiveEnemies(int count) {
    if (count < 2) {
      _addEnemyInWorld();
    }
  }

  void _addEnemyInWorld() {
    double x = DungeonMap.tileSize * (4 + Random().nextInt(25));
    double y = DungeonMap.tileSize * (5 + Random().nextInt(3));

    final goblin = Goblin(Vector2(x, y));

    _controller.addGameComponent(
      AnimatedObjectOnce(
        animation: CommonSpriteSheet.smokeExplosion,
        size: Vector2.all(DungeonMap.tileSize),
        position: goblin.position,
      ),
    );

    _controller.addGameComponent(
      goblin,
    );
  }
}
