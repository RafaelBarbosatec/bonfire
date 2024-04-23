import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/spritefusion/model/spritefucion_map.dart';
import 'package:bonfire/map/spritefusion/reader/spritefusion_asset_reader.dart';
import 'package:bonfire/map/spritefusion/reader/spritefusion_network_reader.dart';
import 'package:bonfire/map/tiled/reader/tiled_asset_reader.dart';
import 'package:bonfire/map/tiled/reader/tiled_network_reader.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';

abstract class WorldMapReader<T> {
  Future<T> readMap();

  String get basePath;

  static WorldMapReader<T> fromAsset<T>(String asset) {
    switch (T) {
      case TiledMap:
        return TiledAssetReader(asset: asset) as WorldMapReader<T>;
      case SpritefusionMap:
        return SpritefusionAssetReader(asset: asset) as WorldMapReader<T>;
      default:
        throw Exception('There is not a WorldMapReader.asset to $T');
    }
  }

  static WorldMapReader<T> fromNetwork<T>(
    Uri uri, {
    TiledCacheProvider? cacheProvider,
    Map<String, String>? headers,
  }) {
    switch (T) {
      case TiledMap:
        return TiledNetworkReader(
          uri: uri,
          cacheProvider: cacheProvider,
          headers: headers,
        ) as WorldMapReader<T>;
      case SpritefusionMap:
        return SpritefusionNetworkReader(
          uri: uri,
          cacheProvider: cacheProvider,
          headers: headers,
        ) as WorldMapReader<T>;
      default:
        throw Exception('There is not a WorldMapReader.network to $T');
    }
  }
}
