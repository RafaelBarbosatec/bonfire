import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class SpritefusionPage extends StatelessWidget {
  const SpritefusionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return BonfireWidget(
      playerControllers: [
        Joystick(
          directional: JoystickDirectional(),
        )
      ],
      map: WorldMapBySpritefusion(
        WorldMapReader.fromAsset('spritefusion/map.json'),
      ),
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 20),
        initPosition: Vector2(tileSize * 5, tileSize * 5),
      ),
    );
  }
}
