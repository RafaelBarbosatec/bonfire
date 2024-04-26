import 'package:bonfire/bonfire.dart';
import 'package:example/pages/input/move_camera_mouse/barrel_enable_move_camera.dart';
import 'package:flutter/widgets.dart';

class MoveCameraPage extends StatelessWidget {
  const MoveCameraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return BonfireWidget(
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/tiled_example.tmj'),
      ),
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 30),
        initPosition: Vector2(tileSize * 5, tileSize * 7),
      ),
      components: [
        BarrelEnableMoveCamera(
          position: Vector2(tileSize * 5, tileSize * 5),
        ),
      ],
    );
  }
}
