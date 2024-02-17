import 'package:bonfire/bonfire.dart';
import 'package:example/pages/parallax/bonfire/bonfire_parallax_background.dart';
import 'package:example/pages/player/platform/simple_fox_player.dart';
import 'package:flutter/material.dart';

class BonfireParallaxPage extends StatelessWidget {
  const BonfireParallaxPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(
        directional: JoystickDirectional(),
        keyboardConfig: KeyboardConfig(),
      ),
      map: WorldMapByTiled(
        TiledReader.asset('platform/parallax_map.tmj'),
      ),
      background: BonfireParallaxBackground(),
      globalForces: [GravityForce2D()],
      player: SimpleFoxPlayer(position: Vector2.all(50)),
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        initialMapZoomFit: InitialMapZoomFitEnum.fitHeight,
      ),
    );
  }
}
