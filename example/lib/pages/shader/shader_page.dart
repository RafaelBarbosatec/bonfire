import 'package:bonfire/bonfire.dart';
import 'package:example/pages/shader/shader_layer_configuration.dart';
import 'package:flutter/material.dart';

class ShaderPage extends StatelessWidget {
  const ShaderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('solaria/map.tmj'),
      ),
      playerControllers: [
        Joystick(directional: JoystickDirectional()),
        Keyboard(),
      ],
      cameraConfig: CameraConfig(
        initialMapZoomFit: InitialMapZoomFitEnum.fitWidth,
        // moveOnlyMapArea: true,
      ),
      components: [
        ShaderConfiguration(),
      ],
    );
  }
}
