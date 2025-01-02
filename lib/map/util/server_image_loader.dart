import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:http/http.dart' as http;

class ServerImageLoader {
  static const _keyImgBase64 = 'base64';
  final TiledCacheProvider cache;
  final Map<String, String>? headers;

  ServerImageLoader({
    required this.cache,
    this.headers,
  });
  Future<Image?> load(String url) async {
    if (!Flame.images.containsKey(url)) {
      final containCache = await cache.containsKey(url);
      if (containCache) {
        final base64 = (await cache.get(url))[_keyImgBase64].toString();
        return Flame.images.fromBase64(url, base64);
      } else {
        final response = await http.get(Uri.parse(url), headers: headers);
        final img64 = base64Encode(response.bodyBytes);
        cache.put(url, {_keyImgBase64: img64});
        return Flame.images.fromBase64(url, img64);
      }
    }
    return Flame.images.load(url);
  }
}
