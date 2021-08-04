import 'dart:convert';
import 'dart:ui';

import 'package:bonfire/map/tile/tile_model.dart';
import 'package:bonfire/util/controlled_update_animation.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:http/http.dart' as http;

class MapAssetsManager {
  static final Map<String, Sprite> spriteCache = Map();
  static final Map<String, ControlledUpdateAnimation> spriteAnimationCache =
      Map();

  static bool inSpriteCache(String key) => spriteCache.containsKey(key);
  static Sprite getSpriteCache(String key) => spriteCache[key]!;
  static Future<Sprite> getSprite(
    String image,
    int row,
    int column,
    double tileWidth,
    double tileHeight, {
    bool fromServer = false,
  }) async {
    if (spriteCache.containsKey('$image/$row/$column')) {
      return Future.value(spriteCache['$image/$row/$column']);
    }
    final spriteSheetImg = await loadImage(image, fromServer: fromServer);
    return spriteCache['$image/$row/$column'] = spriteSheetImg.getSprite(
      x: (column * tileWidth).toDouble(),
      y: (row * tileHeight).toDouble(),
      width: tileWidth,
      height: tileHeight,
    );
  }

  static bool inSpriteAnimationCache(String key) {
    return spriteAnimationCache.containsKey(key);
  }

  static ControlledUpdateAnimation getSpriteAnimationCache(String key) {
    return spriteAnimationCache[key]!;
  }

  static Future<ControlledUpdateAnimation> getSpriteAnimation(
    List<TileModelSprite> frames,
    double stepTime,
  ) async {
    String key = '';
    List<Sprite> spriteList = [];

    await Future.forEach<TileModelSprite>(frames, (frame) async {
      Sprite sprite = await MapAssetsManager.getSprite(
        frame.path,
        frame.row,
        frame.column,
        frame.width,
        frame.height,
        fromServer: frame.path.contains('http'),
      );
      key += '${frame.path}${frame.row}${frame.column}';
      spriteList.add(sprite);
    });

    return spriteAnimationCache[key] = ControlledUpdateAnimation.fromInstance(
      SpriteAnimation.spriteList(
        spriteList,
        stepTime: stepTime,
      ),
    );
  }

  static Future<Image> loadImage(
    String image, {
    bool fromServer = false,
  }) async {
    if (fromServer) {
      final imageCache = getImageFromCache(image);
      if (imageCache != null) {
        return imageCache;
      }
      final response = await http.get(Uri.parse(image));
      String img64 = base64Encode(response.bodyBytes);
      return Flame.images.fromBase64(image, img64);
    } else {
      return Flame.images.load(image);
    }
  }

  static Image? getImageFromCache(String image) {
    try {
      return Flame.images.fromCache(image);
    } catch (e) {
      return null;
    }
  }
}
