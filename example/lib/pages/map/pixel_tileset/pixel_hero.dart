import 'package:bonfire/bonfire.dart';

/// A tiny player entirely drawn with a [PixelTileset] sprite - no image
/// asset involved, see [PixelTilesetPage].
class PixelHero extends Player with WithCollision {
  final Sprite sprite;

  PixelHero({
    required Vector2 position,
    required double tileSize,
    required this.sprite,
  }) : super(
          position: position,
          size: Vector2.all(tileSize),
          speed: tileSize * 4,
        ) {
    setupMovementByJoystick();
  }

  @override
  void onMount() {
    add(
      RectangleHitbox(
        size: size * 0.6,
        position: size * 0.2,
      ),
    );
    super.onMount();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite.render(canvas, size: size);
  }
}
