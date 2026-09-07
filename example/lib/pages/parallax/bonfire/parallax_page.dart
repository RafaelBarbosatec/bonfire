import 'package:bonfire/bonfire.dart';
import 'package:example/pages/parallax/flame/parallax_background.dart';
import 'package:example/pages/player/platform/simple_fox_player.dart';
import 'package:flutter/material.dart';

class ParallaxPage extends StatelessWidget {
  const ParallaxPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      playerControllers: [
        Joystick(
          directional: JoystickDirectional(),
        )
      ],
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('platform/parallax_map.tmj'),
      ),
      background: ParallaxBackground(),
      globalForces: GlobalForcesSettings(
        gravity: Vector2(0, 300),
      ),
      player: SimpleFoxPlayer(position: Vector2.all(50)),
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        initialMapZoomFit: InitialMapZoomFitEnum.fitHeight,
      ),
    );
  }
}
