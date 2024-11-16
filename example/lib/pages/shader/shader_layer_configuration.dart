import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';

import 'shader_config_controller.dart';

class ShaderConfiguration extends GameComponent {
  late ui.FragmentShader shader;

  late ui.Image noiseGradiente;
  late ui.Image valueGradiente;

  final Color toneColor = const Color(0xFF5ca4ec);
  final Color lightColor = const Color(0xFFffffff);
  final ShaderConfigController controller;

  ShaderConfiguration({required this.controller});

  @override
  Future<void> onLoad() async {
    final progam = await ui.FragmentProgram.fromAsset(
      'shaders/waterShaderV2.frag',
    );
    shader = progam.fragmentShader();
    noiseGradiente = await Flame.images.load('noise/gradiente_noise.png');
    valueGradiente = await Flame.images.load('noise/value_noise.png');

    ShaderSetter(
      values: [
        SetterImage(noiseGradiente),
        SetterImage(valueGradiente),
        SetterDouble(controller.config.distortionStrength),
        SetterVector2(Vector2.all(controller.config.speed)),
        SetterColor(controller.config.toneColor),
        SetterColor(controller.config.lightColor),
        SetterDouble(controller.config.opacity),
        SetterVector2(controller.config.lightRange),
      ],
    ).apply(shader);

    return super.onLoad();
  }

  @override
  void onRemove() {
    super.onRemove();
    controller.removeListener(_controllerListener);
  }

  @override
  void onGameMounted() {
    super.onGameMounted();
    _setupShader();
  }

  void _setupShader() {
    final layer = gameRef.map.layersComponent.elementAtOrNull(1);
    layer?.shader = shader;
    layer?.shaderComponentStatic = true;
    controller.addListener(_controllerListener);
  }

  void _controllerListener() {
    ShaderSetter(
      values: [
        SetterDouble(controller.config.distortionStrength),
        SetterVector2(Vector2.all(controller.config.speed)),
        SetterColor(controller.config.toneColor),
        SetterColor(controller.config.lightColor),
        SetterDouble(controller.config.opacity),
        SetterVector2(controller.config.lightRange),
      ],
    ).apply(shader);
  }
}
