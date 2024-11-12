import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
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

class ShaderConfiguration extends GameComponent {
  late ui.FragmentShader shader;

  late ui.Image noise;

  final Color toneColor = const Color(0xFF5ca4ec);

  @override
  Future<void> onLoad() async {
    final progam =
        await ui.FragmentProgram.fromAsset('shaders/waterShader.frag');
    shader = progam.fragmentShader();
    noise = await Flame.images.load('noise.png');
    return super.onLoad();
  }

  @override
  void update(double dt) {
    shader.setImageSampler(1, noise);
    shader.setFloat(3, 0.05); //scroll x
    shader.setFloat(4, 0.05); //scroll y
    shader.setFloat(5, toneColor.red / 255 * toneColor.opacity);
    shader.setFloat(6, toneColor.green / 255 * toneColor.opacity);
    shader.setFloat(7, toneColor.blue / 255 * toneColor.opacity);
    shader.setFloat(8, toneColor.opacity);
    super.update(dt);
  }

  @override
  void onMount() {
    _loadShader();
    super.onMount();
  }

  Future<void> _loadShader() async {
    await Future.delayed(Duration.zero);
    final layer = gameRef.map.layersComponent.elementAtOrNull(1);
    layer?.shader = shader;
  }
}
