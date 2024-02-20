import 'package:bonfire/bonfire.dart';

class BonfireParallaxBackground extends GameBackground {
  @override
  void onMount() {
    _addParallax();
    super.onMount();
  }

  void _addParallax() async {
    final p = await loadCameraParallaxComponent(
      [
        ParallaxImageData('platform/back.png'),
        ParallaxImageData('platform/middle.png'),
      ],
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );
    add(p);
  }
}
