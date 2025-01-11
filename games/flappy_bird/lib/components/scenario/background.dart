import 'package:bonfire/bonfire.dart';

class ParallaxBackground extends GameBackground {
  final double speed;

  ParallaxBackground({required this.speed});
  @override
  void onMount() {
    _addParallax();
    super.onMount();
  }

  void _addParallax() async {
    final p = await loadParallaxComponent(
      [
        ParallaxImageData('background-day.png'),
      ],
      baseVelocity: Vector2(speed * 0.5, 0),
    );
    add(p);
  }
}
