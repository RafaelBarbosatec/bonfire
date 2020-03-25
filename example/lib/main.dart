import 'package:bonfire/bonfire.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:example/player/knight.dart';
import 'package:example/player/knight_interface.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.setLandscape();
  await Flame.util.fullScreen();
  runApp(
    MaterialApp(
      home: Game(),
    ),
  );
}

class Game extends StatelessWidget {
  static const sizeTile = 32.0;
  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(
        pathSpriteBackgroundDirectional: 'joystick_background.png',
        pathSpriteKnobDirectional: 'joystick_knob.png',
        sizeDirectional: 100,
        actions: [
          JoystickAction(
            actionId: 0,
            pathSprite: 'joystick_atack.png',
            size: 80,
            marginBottom: 50,
            marginRight: 50,
          ),
          JoystickAction(
            actionId: 1,
            pathSprite: 'joystick_atack_range.png',
            size: 50,
            marginBottom: 50,
            marginRight: 160,
          )
        ],
      ),
      player: Knight(
        initPosition: Position(5 * sizeTile, 6 * sizeTile),
      ),
      interface: KnightInterface(),
      map: DungeonMap.map(),
      decorations: DungeonMap.decorations(),
      enemies: DungeonMap.enemies(),
      background: BackgroundColorGame(Colors.blueGrey[900]),
      listener: (context, game) {
        // TODO ANYTHINGS
      },
    );
  }
}
