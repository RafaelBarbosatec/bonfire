import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';

class ShaderConfiguration extends GameComponent {
  late ui.FragmentShader shader;

  late ui.Image noiseGradiente;
  late ui.Image valueGradiente;

  final Color toneColor = const Color(0xFF5ca4ec);
  final Color lightColor = const Color(0xFFffffff);

  @override
  Future<void> onLoad() async {
    final progam = await ui.FragmentProgram.fromAsset(
      'shaders/waterShaderV2.frag',
    );
    shader = progam.fragmentShader();
    noiseGradiente = await Flame.images.load('noise/gradiente_noise.png');
    valueGradiente = await Flame.images.load('noise/value_noise.png');

    ShaderSetter(values: [
      SetterImage(noiseGradiente),
      SetterImage(valueGradiente),
      SetterDouble(0.05),
      SetterVector2(Vector2.all(0.04)),
      SetterColor(toneColor),
      SetterColor(lightColor),
    ]).apply(shader);

    // shader.setImageSampler(1, noiseGradiente); // noise
    // shader.setImageSampler(2, valueGradiente); // noise
    // shader.setFloat(3, 0.05); //distorion Strength
    // shader.setFloat(4, 0.04); //scroll x
    // shader.setFloat(5, 0.04); //scroll y

    // // tone color
    // shader.setFloat(6, toneColor.red / 255 * toneColor.opacity);
    // shader.setFloat(7, toneColor.green / 255 * toneColor.opacity);
    // shader.setFloat(8, toneColor.blue / 255 * toneColor.opacity);
    // shader.setFloat(9, toneColor.opacity);

    // // light color
    // shader.setFloat(10, lightColor.red / 255 * toneColor.opacity);
    // shader.setFloat(11, lightColor.green / 255 * toneColor.opacity);
    // shader.setFloat(12, lightColor.blue / 255 * toneColor.opacity);
    // shader.setFloat(13, lightColor.opacity);
    return super.onLoad();
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
    layer?.shaderComponentStatic = true;
  }
}
