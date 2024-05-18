import 'package:bonfire/bonfire.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/widgets.dart';

import '../player/simple/human.dart';

class PlayerControllersPage extends StatelessWidget {
  const PlayerControllersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    final secondPlayer = HumanPlayer(
      position: Vector2(tileSize * 9, tileSize * 6),
    );
    return BonfireWidget(
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/punnyworld/simple_map.tmj'),
      ),
      playerControllers: [
        Joystick(
          directional: JoystickDirectional(
            alignment: Alignment.centerLeft,
          ),
        ),
        Keyboard(
          config: KeyboardConfig(
            directionalKeys: [
              KeyboardDirectionalKeys.arrows(),
            ],
          ),
        ),
        // Controlles of second player
        Joystick(
          directional: JoystickDirectional(alignment: Alignment.centerRight),
          observer: secondPlayer,
        ),
        Keytest(
          secondPlayer,
        ),
      ],
      player: HumanPlayer(
        position: Vector2(tileSize * 5, tileSize * 6),
      ),
      components: [secondPlayer],
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 20),
      ),
      backgroundColor: const Color(0xff20a0b4),
    );
  }
}

class Keytest extends Keyboard {
  Keytest(PlayerControllerListener o)
      : super(
            config: KeyboardConfig(
              directionalKeys: [
                KeyboardDirectionalKeys.wasd(),
              ],
            ),
            observer: o);

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    print(keyboardConfig.directionalKeys.first.down);
    return super.onKeyboard(event, keysPressed);
  }
}
