import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/platform/fox_player.dart';
import 'package:flutter/widgets.dart';

class PlatformPlayerPage extends StatelessWidget {
  const PlatformPlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return BonfireWidget(
      map: WorldMapByTiled(
        'platform/simple_map.tmj',
      ),
      joystick: Joystick(
        keyboardConfig: KeyboardConfig(),
        directional: JoystickDirectional(),
        actions: [
          JoystickAction(
            actionId: 1,
            margin: const EdgeInsets.all(50),
          ),
        ],
      ),
      player: FoxPlayer(
        position: Vector2(tileSize * 7, tileSize * 3),
      ),
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 20),
      ),
      globalForces: [GravityForce2D()],
      backgroundColor: const Color(0xff2fbdff),
    );
  }
}
