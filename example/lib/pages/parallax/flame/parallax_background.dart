import 'package:bonfire/bonfire.dart';

class ParallaxBackground extends GameBackground {
  @override
  void onGameMounted() {
    _addParallax();
    super.onGameMounted();
  }

  void _addParallax() async {
    final p = await loadParallaxComponent(
      [
        ParallaxImageData('platform/back.png'),
        ParallaxImageData('platform/middle.png'),
      ],
      size: gameRef.camera.canvasSize,
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );
    add(p);
  }
}
