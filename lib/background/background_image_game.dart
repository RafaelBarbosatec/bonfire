///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 30/11/21
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/map_assets_manager.dart';

class BackgroundImageGame extends GameBackground {
  final String imagePath;
  final Vector2 offset;
  final double factor;
  final double parallaxX;
  final double parallaxY;
  final double opacity;

  Sprite? imageSprite;
  BackgroundImageGame({
    required this.offset,
    required this.imagePath,
    this.factor = 1,
    this.parallaxX = 1,
    this.parallaxY = 1,
    this.opacity = 1,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    imageSprite?.renderFromVector2Rect(canvas, position, opacity: opacity);
  }

  @override
  void update(double dt) {
    position = position.copyWith(
      position: Vector2(
        gameRef.camera.position.dx * -1 * parallaxX,
        gameRef.camera.position.dy * -1 * parallaxY,
      ),
    );
    super.update(dt);
  }

  @override
  Future<void>? onLoad() async {
    imageSprite = await MapAssetsManager.getFutureSprite(imagePath);
    position = Rect.fromLTWH(
            offset.x,
            offset.y,
            imageSprite!.image.width * factor,
            imageSprite!.image.height * factor)
        .toVector2Rect();
    return super.onLoad();
  }
}
