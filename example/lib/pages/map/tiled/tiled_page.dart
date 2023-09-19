import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class TiledPage extends StatelessWidget {
  const TiledPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(directional: JoystickDirectional()),
      map: WorldMapByTiled('tiled/tiled_example.tmj'),
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, 16, 30),
      ),
    );
  }
}
