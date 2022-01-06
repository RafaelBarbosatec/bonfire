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
import 'package:bonfire/map/map_assets_manager.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';

/// Used to define parallax image as background
class BackgroundImageGame extends GameBackground {
  final String imagePath;
  final Vector2 offset;
  final double factor;
  final double parallaxX;
  final double parallaxY;
  final double opacity;
  Vector2 _parallaxOffset = Vector2.zero();

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
    imageSprite?.renderWithOpacity(
      canvas,
      position,
      size,
      opacity: opacity,
    );
  }

  @override
  void update(double dt) {
    position = _parallaxOffset.translate(
      (gameRef.camera.position.x * -1 * parallaxX),
      (gameRef.camera.position.y * -1 * parallaxY),
    );
    super.update(dt);
  }

  @override
  Future<void>? onLoad() async {
    imageSprite = await MapAssetsManager.getFutureSprite(imagePath);
    _parallaxOffset = Vector2(offset.x * factor, offset.y * factor);
    position = _parallaxOffset.clone();
    size = Vector2(
      imageSprite!.image.width * factor,
      imageSprite!.image.height * factor,
    );

    return super.onLoad();
  }
}
