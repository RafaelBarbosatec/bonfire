import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/rotation/human_topdown_player.dart';
import 'package:flutter/widgets.dart';

class RotationPlayerPage extends StatelessWidget {
  const RotationPlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return BonfireWidget(
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/simple_topdown/simple.tmj'),
      ),
      playerControllers: [
        Joystick(
          directional: JoystickDirectional(),
        )
      ],
      player: HumanTopdownPlayer(
        position: Vector2(5 * tileSize, 5 * tileSize),
      ),
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 20),
      ),
    );
  }
}
