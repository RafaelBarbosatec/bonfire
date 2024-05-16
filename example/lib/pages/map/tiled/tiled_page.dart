import 'package:bonfire/bonfire.dart';
import 'package:example/shared/decoration/spikes.dart';
import 'package:flutter/material.dart';

class TiledPage extends StatelessWidget {
  const TiledPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return BonfireWidget(
      playerControllers: [
        Joystick(
          directional: JoystickDirectional(),
        )
      ],
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/tiled_example.tmj'),
        objectsBuilder: {
          'spikes': (props) => Spikes(
                props.position,
                size: props.size,
              ),
        },
      ),
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 20),
        initPosition: Vector2(tileSize * 5, tileSize * 5),
      ),
    );
  }
}
