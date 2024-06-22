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
          actions: [
            JoystickAction(
              actionId: 1,
              margin: const EdgeInsets.all(50),
            ),
          ],
        ),
      ],
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('platform/parallax_map.tmj'),
      ),
      background: ParallaxBackground(),
      globalForces: [GravityForce2D()],
      player: SimpleFoxPlayer(position: Vector2.all(50)),
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        initialMapZoomFit: InitialMapZoomFitEnum.fitHeight,
      ),
    );
  }
}
