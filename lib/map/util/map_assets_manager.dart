import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/controlled_update_animation.dart';

class MapAssetsManager {
  static final Map<String, Sprite> spriteCache = {};
  static final Map<String, ControlledUpdateAnimation> spriteAnimationCache = {};

  static Sprite getSprite(
    String image,
    Vector2 position,
    Vector2 size,
  ) {
    String pathCache = '$image/${position.x}/${position.y}';
    if (spriteCache.containsKey(pathCache)) {
      return spriteCache[pathCache]!;
    }

    Image? spriteSheetImg = getImageCache(image);

    return spriteCache[pathCache] = spriteSheetImg!.getSprite(
      position: Vector2(position.x * size.x, position.y * size.y),
      size: Vector2(
        size.x == 0.0 ? spriteSheetImg.width.toDouble() : size.x,
        size.y == 0.0 ? spriteSheetImg.height.toDouble() : size.y,
      ),
    );
  }

  static Future<Sprite> getFutureSprite(
    String image, {
    Vector2? position,
    Vector2? size,
  }) async {
    String pathCache = '$image/${position?.x ?? 0}/${position?.y ?? 0}';

    if (spriteCache.containsKey(pathCache)) {
      return Future.value(spriteCache[pathCache]);
    }

    Image spriteSheetImg = await loadImage(
      image,
    );

    return spriteCache[pathCache] = spriteSheetImg.getSprite(
      position: Vector2(
        ((position?.x ?? 0.0) * (size?.x ?? 0.0)),
        ((position?.y ?? 0.0) * (size?.y ?? 0.0)),
      ),
      size: Vector2(
        (size?.x ?? 0.0) == 0.0 ? spriteSheetImg.width.toDouble() : size!.x,
        (size?.y ?? 0.0) == 0.0 ? spriteSheetImg.height.toDouble() : size!.y,
      ),
    );
  }

  static Future<SpriteAnimation> getFutureSpriteAnimation(
    List<TileSprite> frames,
    double stepTime,
  ) async {
    List<Sprite> spriteList = [];

    for (var frame in frames) {
      Sprite sprite = await MapAssetsManager.getFutureSprite(
        frame.path,
        position: frame.position,
        size: frame.size,
      );
      spriteList.add(sprite);
    }

    return SpriteAnimation.spriteList(
      spriteList,
      stepTime: stepTime,
    );
  }

  static ControlledUpdateAnimation getSpriteAnimation(
    List<TileSprite> frames,
    double stepTime,
  ) {
    String key = '';
    List<Sprite> spriteList = [];

    for (var frame in frames) {
      Sprite sprite = MapAssetsManager.getSprite(
        frame.path,
        frame.position,
        frame.size,
      );
      key += '${frame.path}${frame.position.x}${frame.position.y}';
      spriteList.add(sprite);
    }

    if (spriteAnimationCache.containsKey(key)) {
      return spriteAnimationCache[key]!;
    }

    return spriteAnimationCache[key] =
        ControlledUpdateAnimation.fromSpriteAnimation(
      SpriteAnimation.spriteList(
        spriteList,
        stepTime: stepTime,
      ),
    );
  }

  static Future<Image> loadImage(
    String image,
  ) {
    return Flame.images.load(image);
  }

  static Image? getImageCache(String image) {
    try {
      return Flame.images.fromCache(image);
    } catch (e) {
      return null;
    }
  }
}
