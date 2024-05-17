import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/simple/human.dart';
import 'package:flutter/widgets.dart';

class SimplePlayerPage extends StatelessWidget {
  const SimplePlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return BonfireWidget(
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/punnyworld/simple_map.tmj'),
      ),
      playerControllers: [
        Joystick(directional: JoystickDirectional()),
        Keyboard(),
      ],
      player: HumanPlayer(
        position: Vector2(tileSize * 7, tileSize * 6),
      ),
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 20),
      ),
      backgroundColor: const Color(0xff20a0b4),
    );
  }
}
