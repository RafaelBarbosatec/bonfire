import 'dart:async';

import 'package:bonfire/tiled/cache_provider/tiled_cache_provider.dart';
import 'package:bonfire/tiled/reader/tiled_asset_reader.dart';
import 'package:bonfire/tiled/reader/tiled_network_reader.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';

abstract class TiledReader {
  Future<TiledMap> readMap();

  String get basePath;

  static TiledReader asset(String asset) {
    return TiledAssetReader(asset: asset);
  }

  static TiledReader network(
    Uri uri, {
    TiledCacheProvider? cacheProvider,
    Map<String, String>? headers,
  }) {
    return TiledNetworkReader(
      uri: uri,
      cacheProvider: cacheProvider,
      headers: headers,
    );
  }
}
