import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';

class ShaderConfiguration extends GameComponent {
  late ui.FragmentShader shader;

  late ui.Image noiseGradiente;
  late ui.Image valueGradiente;

  final Color toneColor = const Color(0xFF5ca4ec);

  @override
  Future<void> onLoad() async {
    final progam = await ui.FragmentProgram.fromAsset(
      'shaders/waterShaderV2.frag',
    );
    shader = progam.fragmentShader();
    noiseGradiente = await Flame.images.load('noise/gradiente_noise.png');
    valueGradiente = await Flame.images.load('noise/value_noise.png');
    shader.setImageSampler(1, noiseGradiente); // noise
    shader.setImageSampler(2, valueGradiente); // noise
    shader.setFloat(3, 0.05); //scroll x
    shader.setFloat(4, 0.05); //scroll y
    shader.setFloat(5, toneColor.red / 255 * toneColor.opacity);
    shader.setFloat(6, toneColor.green / 255 * toneColor.opacity);
    shader.setFloat(7, toneColor.blue / 255 * toneColor.opacity);
    shader.setFloat(8, toneColor.opacity);
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
  }
}
