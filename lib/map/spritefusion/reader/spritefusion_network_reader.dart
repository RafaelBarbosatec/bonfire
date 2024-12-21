import 'dart:convert';

import 'package:bonfire/map/spritefusion/model/spritefucion_map.dart';
import 'package:bonfire/map/tiled/cache_provider/tiled_cache_provider.dart';
import 'package:bonfire/map/tiled/cache_provider/tiled_memory_cache_provider.dart';
import 'package:bonfire/map/util/server_image_loader.dart';
import 'package:bonfire/map/util/world_map_reader.dart';
import 'package:http/http.dart' as http;

class SpritefusionNetworkReader extends WorldMapReader<SpritefusionMap> {
  final Uri uri;
  final TiledCacheProvider cache;
  final Map<String, String>? headers;

  late ServerImageLoader _imageLoader;

  @override
  late String basePath;

  SpritefusionNetworkReader({
    required this.uri,
    TiledCacheProvider? cacheProvider,
    this.headers,
  }) : cache = cacheProvider ?? TiledMemoryCacheProvider() {
    _imageLoader = ServerImageLoader(cache: cache);
    final url = uri.toString();
    basePath = url.replaceAll(url.split('/').last, '');
  }

  @override
  Future<SpritefusionMap> readMap() async {
    final map = await _fetchMap();
    await _imageLoader.load(map.imgPath);
    return map;
  }

  Future<SpritefusionMap> _fetchMap() async {
    final uriKey = uri.toString();
    final containCache = await cache.containsKey(uriKey);
    if (containCache) {
      final map = await cache.get(uriKey);
      return SpritefusionMap.fromMap(map);
    } else {
      final mapResponse = await http.get(uri, headers: headers);
      final map = (jsonDecode(mapResponse.body) as Map).cast<String, dynamic>();
      map['imgPath'] = '${basePath}spritesheet.png';
      cache.put(uriKey, map.cast());
      return SpritefusionMap.fromMap(map);
    }
  }
}
