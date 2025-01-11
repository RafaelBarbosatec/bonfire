import 'package:bonfire/bonfire.dart';

class ParallaxBaseBackground extends GameComponent {
  static const baseHeight = 112.0;
  final double speed;

  ParallaxBaseBackground({required this.speed});
  @override
  void onMount() {
    final gameSize = gameRef.map.size;
    size = gameSize.copyWith(
      y: baseHeight,
    );
    position = position.copyWith(
      y: gameSize.y - baseHeight,
    );
    add(
      RectangleHitbox(
        size: size,
        isSolid: true,
      ),
    );
    _addParallax();
    super.onMount();
  }

  void _addParallax() async {
    final p = await loadParallaxComponent(
      [
        ParallaxImageData('base.png'),
      ],
      baseVelocity: Vector2(speed, 0),
      size: size,
    );
    add(p);
  }

  @override
  int get priority => LayerPriority.BACKGROUND + 10;
}
