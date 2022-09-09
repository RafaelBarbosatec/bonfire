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
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';

/// Used to define parallax image as background
class BackgroundImageGame extends GameBackground with UseSprite {
  final int? id;
  final String imagePath;
  final Vector2 offset;
  final double factor;
  final double parallaxX;
  final double parallaxY;
  final bool isBackground;
  final int priorityImage;
  Vector2 _parallaxOffset = Vector2.zero();

  BackgroundImageGame({
    required this.offset,
    required this.imagePath,
    this.id,
    this.factor = 1,
    this.parallaxX = 1,
    this.parallaxY = 1,
    double opacity = 1,
    this.isBackground = true,
    this.priorityImage = 0,
  }) {
    opacity = opacity;
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
    sprite = await MapAssetsManager.getFutureSprite(imagePath);
    _parallaxOffset = Vector2(offset.x * factor, offset.y * factor);
    position = _parallaxOffset.clone();
    size = Vector2(
      sprite!.image.width * factor,
      sprite!.image.height * factor,
    );

    return super.onLoad();
  }

  @override
  int get priority {
    if (isBackground) {
      return LayerPriority.BACKGROUND + priorityImage;
    } else {
      return LayerPriority.MAP + 1 + priorityImage;
    }
  }
}
