import 'package:bonfire/bonfire.dart';
import 'package:example/pages/lighting/simple_torch.dart';
import 'package:flutter/material.dart';

class LightingPage extends StatelessWidget {
  const LightingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return BonfireWidget(
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/tiled_example.tmj'),
        objectsBuilder: {
          'torch': (prop) => SimpleTorch(prop.position),
        },
      ),
      lightingColorGame: Colors.black.withOpacity(0.8),
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 30),
        initPosition: Vector2(tileSize * 5, tileSize * 5),
      ),
    );
  }
}
