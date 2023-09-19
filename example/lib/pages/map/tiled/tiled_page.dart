import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class TiledPage extends StatelessWidget {
  const TiledPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return BonfireWidget(
      joystick: Joystick(directional: JoystickDirectional()),
      map: WorldMapByTiled('tiled/tiled_example.tmj'),
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 30),
        initPosition: Vector2(tileSize * 10, tileSize * 5),
      ),
    );
  }
}
