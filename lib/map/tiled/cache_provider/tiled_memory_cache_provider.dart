import 'package:bonfire/map/tiled/cache_provider/tiled_cache_provider.dart';

class TiledMemoryCacheProvider extends TiledCacheProvider {
  static final TiledMemoryCacheProvider _singleton =
      TiledMemoryCacheProvider._internal();

  factory TiledMemoryCacheProvider() {
    return _singleton;
  }

  TiledMemoryCacheProvider._internal();

  final Map<String, Map<String, dynamic>> _cache = {};

  @override
  Future<Map<String, dynamic>> get(String key) {
    if (_cache.containsKey(key)) {
      return Future.value(_cache[key]);
    }
    throw Exception('Not contain cache to key $key');
  }

  @override
  void put(String key, Map<String, dynamic> data) {
    _cache[key] = data;
  }

  @override
  Future<bool> containsKey(String key) {
    return Future.value(_cache.containsKey(key));
  }
}
