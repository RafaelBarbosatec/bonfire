import 'package:bonfire/bonfire.dart';
import 'package:example/pages/input/mouse/barrel_show_mouse_input.dart';
import 'package:flutter/widgets.dart';

class MouseInputPage extends StatelessWidget {
  const MouseInputPage({Key? key}) : super(key: key);

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
        BarrelShowMouseInput(
          position: Vector2(tileSize * 5, tileSize * 5),
        ),
      ],
    );
  }
}
