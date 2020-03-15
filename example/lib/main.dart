import 'package:bonfire/bonfire.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:example/player/knight.dart';
import 'package:example/player/knight_interface.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.setLandscape();
  await Flame.util.fullScreen();
  Size size = await Flame.util.initialDimensions();
  runApp(
    MaterialApp(
      home: Game(
        size: size,
      ),
    ),
  );
}

class Game extends StatelessWidget {
  final Size size;

  const Game({Key key, this.size}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(
        screenSize: size,
        actions: [
          JoystickAction(
            actionId: 0,
            pathSprite: 'joystick_atack.png',
            size: 50,
            marginBottom: 50,
            marginRight: 50,
          ),
          JoystickAction(
            actionId: 1,
            pathSprite: 'joystick_atack_range.png',
            size: 50,
            marginTop: 50,
            marginRight: 50,
            align: JoystickActionAlign.TOP,
          )
        ],
      ),
      player: Knight(
        initPosition: Position(5, 6),
      ),
      interface: KnightInterface(),
      map: DungeonMap.map(),
      decorations: DungeonMap.decorations(),
      enemies: DungeonMap.enemies(),
    );
  }
}
