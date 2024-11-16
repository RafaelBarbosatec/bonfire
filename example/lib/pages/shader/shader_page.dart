import 'package:bonfire/bonfire.dart';
import 'package:example/pages/shader/shader_layer_configuration.dart';
import 'package:flutter/material.dart';

import 'shader_config_controller.dart';
import 'shader_config_panel.dart';

class ShaderPage extends StatefulWidget {
  const ShaderPage({Key? key}) : super(key: key);

  @override
  State<ShaderPage> createState() => _ShaderPageState();
}

class _ShaderPageState extends State<ShaderPage> {
  late ShaderConfigController controller;

  @override
  void initState() {
    controller = ShaderConfigController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: BonfireWidget(
            map: WorldMapByTiled(
              WorldMapReader.fromAsset('solaria/map.tmj'),
            ),
            playerControllers: [
              Joystick(directional: JoystickDirectional()),
              Keyboard(),
            ],
            cameraConfig: CameraConfig(
              initialMapZoomFit: InitialMapZoomFitEnum.fitWidth,
              moveOnlyMapArea: true,
            ),
            components: [
              ShaderConfiguration(controller: controller),
            ],
          ),
        ),
        Expanded(
            child: ShaderConfigPanel(
          controller: controller,
        )),
      ],
    );
  }
}
