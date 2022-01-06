import 'dart:convert';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/controlled_update_animation.dart';
import 'package:http/http.dart' as http;

class MapAssetsManager {
  static final Map<String, Sprite> spriteCache = Map();
  static final Map<String, Image> _imageCache = Map();
  static final Map<String, ControlledUpdateAnimation> spriteAnimationCache =
      Map();

  static Sprite getSprite(
    String image,
    int row,
    int column,
    double tileWidth,
    double tileHeight,
  ) {
    if (spriteCache.containsKey('$image/$row/$column')) {
      return spriteCache['$image/$row/$column']!;
    }

    Image? spriteSheetImg = getImageCache(image);

    return spriteCache['$image/$row/$column'] = spriteSheetImg!.getSprite(
      position: Vector2(
        (column * tileWidth).toDouble(),
        (row * tileHeight).toDouble(),
      ),
      size: Vector2(
        tileWidth == 0.0 ? spriteSheetImg.width.toDouble() : tileWidth,
        tileHeight == 0.0 ? spriteSheetImg.height.toDouble() : tileHeight,
      ),
    );
  }

  static Future<Sprite> getFutureSprite(
    String image, {
    int row = 0,
    int column = 0,
    double tileWidth = 0,
    double tileHeight = 0,
  }) async {
    if (spriteCache.containsKey('$image/$row/$column')) {
      return Future.value(spriteCache['$image/$row/$column']);
    }

    Image spriteSheetImg = await loadImage(
      image,
    );

    return spriteCache['$image/$row/$column'] = spriteSheetImg.getSprite(
      position: Vector2(
        (column * tileWidth).toDouble(),
        (row * tileHeight).toDouble(),
      ),
      size: Vector2(
        tileWidth == 0.0 ? spriteSheetImg.width.toDouble() : tileWidth,
        tileHeight == 0.0 ? spriteSheetImg.height.toDouble() : tileHeight,
      ),
    );
  }

  static Future<SpriteAnimation> getFutureSpriteAnimation(
    List<TileModelSprite> frames,
    double stepTime,
  ) async {
    List<Sprite> spriteList = [];

    for (var frame in frames) {
      Sprite sprite = await MapAssetsManager.getFutureSprite(
        frame.path,
        row: frame.row,
        column: frame.column,
        tileWidth: frame.width,
        tileHeight: frame.height,
      );
      spriteList.add(sprite);
    }

    return Future.value(SpriteAnimation.spriteList(
      spriteList,
      stepTime: stepTime,
    ));
  }

  static ControlledUpdateAnimation getSpriteAnimation(
    List<TileModelSprite> frames,
    double stepTime,
  ) {
    String key = '';
    List<Sprite> spriteList = [];

    for (var frame in frames) {
      Sprite sprite = MapAssetsManager.getSprite(
        frame.path,
        frame.row,
        frame.column,
        frame.width,
        frame.height,
      );
      key += '${frame.path}${frame.row}${frame.column}';
      spriteList.add(sprite);
    }

    if (spriteAnimationCache.containsKey(key)) {
      return spriteAnimationCache[key]!;
    }

    return spriteAnimationCache[key] = ControlledUpdateAnimation.fromInstance(
      SpriteAnimation.spriteList(
        spriteList,
        stepTime: stepTime,
      ),
    );
  }

  static Future<Image> loadImage(
    String image,
  ) async {
    final fromServer = image.contains('http');
    if (_imageCache.containsKey(image)) {
      return Future.value(_imageCache[image]);
    }
    if (fromServer) {
      final response = await http.get(Uri.parse(image));
      String img64 = base64Encode(response.bodyBytes);
      return _imageCache[image] = await Flame.images.fromBase64(image, img64);
    } else {
      return _imageCache[image] = await Flame.images.load(image);
    }
  }

  static Image? getImageCache(String image) {
    try {
      return _imageCache[image];
    } catch (e) {
      return null;
    }
  }
}
