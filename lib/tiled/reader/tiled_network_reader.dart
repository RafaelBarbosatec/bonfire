import 'dart:async';
import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/tiled/cache_provider/tiled_memory_cache_provider.dart';
import 'package:http/http.dart' as http;
import 'package:tiledjsonreader/map/layer/image_layer.dart';
import 'package:tiledjsonreader/map/layer/map_layer.dart';
import 'package:tiledjsonreader/map/tile_set_detail.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tile_set/tile_set_item.dart';

class TiledNetworkReader extends TiledReader {
// ignore: constant_identifier_names
  static const ORIENTATION_SUPPORTED = 'orthogonal';
  final Uri uri;
  final TiledCacheProvider cache;
  @override
  late String basePath;

  TiledNetworkReader({required this.uri, TiledCacheProvider? cacheProvider})
      : cache = cacheProvider ?? TiledMemoryCacheProvider() {
    String url = uri.toString();
    basePath = url.replaceAll(url.split('/').last, '');
  }

  @override
  Future<TiledMap> readMap() async {
    try {
      TiledMap tiledMap = await _fetchMap();

      await Future.forEach<MapLayer>(
        tiledMap.layers ?? [],
        _fetchLayerImage,
      );
      await Future.forEach<TileSetDetail>(
        tiledMap.tileSets ?? [],
        _loadTileset,
      );
      if (tiledMap.orientation != ORIENTATION_SUPPORTED) {
        throw Exception(
          'Orientation not supported. please use $ORIENTATION_SUPPORTED orientation',
        );
      }
      return Future.value(tiledMap);
    } catch (e) {
      // ignore: avoid_print
      print('(TiledReader) Error: $e');
      return Future.value(TiledMap());
    }
  }

  Future<void> preload() => readMap();

  Future<void> _loadTileset(TileSetDetail tileSet) async {
    String sourceBasePath = '';
    if (tileSet.source != null) {
      if (!_isSuppotedFileType(tileSet.source!)) {
        throw Exception('Invalid TileSet source: only supports json files');
      }
      sourceBasePath = tileSet.source!.replaceAll(
        tileSet.source!.split('/').last,
        '',
      );
      final map = await _fetchTileset(tileSet.source!);
      tileSet.updateFromMap(map);
    }

    await _fetchTilesetImage(sourceBasePath, tileSet.image!);
    for (final tile in tileSet.tiles ?? <TileSetItem>[]) {
      if (tile.image?.isNotEmpty == true) {
        await _fetchTilesetImage(sourceBasePath, tile.image!);
      }
    }
  }

  bool _isSuppotedFileType(String source) {
    return (source.contains('.json') || source.contains('.tsj'));
  }

  Future<TiledMap> _fetchMap() async {
    final uriKey = uri.toString();
    bool containCache = await cache.containsKey(uriKey);
    if (containCache) {
      final map = await cache.get(uriKey);
      return TiledMap.fromJson(map);
    } else {
      final mapResponse = await http.get(uri);
      final map = jsonDecode(mapResponse.body);
      cache.put(uriKey, map);
      return TiledMap.fromJson(map);
    }
  }

  Future<Map<String, dynamic>> _fetchTileset(String source) async {
    final uri = Uri.parse('$basePath$source');
    final uriKey = uri.toString();

    bool containCache = await cache.containsKey(uriKey);

    if (containCache) {
      return cache.get(uriKey);
    } else {
      final tileSetResponse = await http.get(
        Uri.parse('$basePath$source'),
      );
      final map = jsonDecode(tileSetResponse.body);
      cache.put(uriKey, map);
      return map;
    }
  }

  Future<void> _fetchTilesetImage(String sourceBasePath, String image) async {
    final url = '$basePath$sourceBasePath$image';
    if (!Flame.images.containsKey(url)) {
      final response = await http.get(Uri.parse(url));
      String img64 = base64Encode(response.bodyBytes);
      await Flame.images.fromBase64(url, img64);
    }
  }

  Future<void> _fetchLayerImage(MapLayer layer) async {
    if (layer is ImageLayer) {
      final url = '$basePath${layer.image}';
      if (!Flame.images.containsKey(url)) {
        final response = await http.get(Uri.parse(url));
        String img64 = base64Encode(response.bodyBytes);
        await Flame.images.fromBase64(url, img64);
      }
    }
  }
}
