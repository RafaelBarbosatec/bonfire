import 'dart:convert';
import 'dart:ui';

import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:http/http.dart' as http;

class AssetsManager {
  static final Map<String, Sprite> spriteCache = Map();

  static Future<Sprite> getSprite(
    String image,
    int row,
    int column,
    double tileWidth,
    double tileHeight,
  ) async {
    if (spriteCache.containsKey('$image/$row/$column')) {
      return Future.value(spriteCache['$image/$row/$column']);
    }
    final spriteSheetImg = await loadImage(image);
    spriteCache['$image/$row/$column'] = spriteSheetImg.getSprite(
      x: (column * tileWidth).toDouble(),
      y: (row * tileHeight).toDouble(),
      width: tileWidth,
      height: tileHeight,
    );
    return Future.value(spriteCache['$image/$row/$column']);
  }

  static Future<Image> loadImage(String image,
      {bool fromServer = false}) async {
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
