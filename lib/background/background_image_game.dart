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

import 'package:bonfire/background/game_background.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/map_assets_manager.dart';
import 'package:flame/sprite.dart';

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
    imageSprite?.renderRectWithOpacity(
      canvas,
      toRect(),
      opacity: opacity,
    );
  }

  @override
  void update(double dt) {
    position = Vector2(
      gameRef.camera.position.x * -1 * parallaxX,
      gameRef.camera.position.y * -1 * parallaxY,
    );
    super.update(dt);
  }

  @override
  Future<void>? onLoad() async {
    imageSprite = await MapAssetsManager.getFutureSprite(imagePath);
    position = Vector2(offset.x, offset.y);
    size = Vector2(
      imageSprite!.image.width * factor,
      imageSprite!.image.height * factor,
    );

    return super.onLoad();
  }
}
