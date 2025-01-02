import 'dart:async';
import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/cache_provider/tiled_memory_cache_provider.dart';
import 'package:bonfire/map/util/server_image_loader.dart';
import 'package:http/http.dart' as http;
import 'package:tiledjsonreader/map/layer/image_layer.dart';
import 'package:tiledjsonreader/map/layer/map_layer.dart';
import 'package:tiledjsonreader/map/tile_set_detail.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tile_set/tile_set_item.dart';

class TiledNetworkReader extends WorldMapReader<TiledMap> {
// ignore: constant_identifier_names
  static const ORIENTATION_SUPPORTED = 'orthogonal';
  final Uri uri;
  final TiledCacheProvider cache;
  final Map<String, String>? headers;
  @override
  late String basePath;
  late ServerImageLoader _imageLoader;

  TiledNetworkReader({
    required this.uri,
    TiledCacheProvider? cacheProvider,
    this.headers,
  }) : cache = cacheProvider ?? TiledMemoryCacheProvider() {
    _imageLoader = ServerImageLoader(cache: cache);
    final url = uri.toString();
    basePath = url.replaceAll(url.split('/').last, '');
  }

  @override
  Future<TiledMap> readMap() async {
    try {
      final tiledMap = await _fetchMap();

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
    var sourceBasePath = '';
    if (tileSet.source != null) {
      if (!_isSuppotedTilesetFileType(tileSet.source!)) {
        throw Exception('Invalid TileSet source: only supports json|tsj files');
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

  bool _isSuppotedTilesetFileType(String source) {
    return source.contains('.json') || source.contains('.tsj');
  }

  bool _isSuppotedMapFileType(String source) {
    return source.contains('.json') || source.contains('.tmj');
  }

  Future<TiledMap> _fetchMap() async {
    final uriKey = uri.toString();
    final containCache = await cache.containsKey(uriKey);
    if (containCache) {
      final map = await cache.get(uriKey);
      return TiledMap.fromJson(map);
    } else {
      if (!_isSuppotedMapFileType(uriKey)) {
        throw Exception('Invalid TileMap source: only supports json|tmj files');
      }
      final mapResponse = await http.get(uri, headers: headers);
      final map = (jsonDecode(mapResponse.body) as Map).cast<String, dynamic>();
      cache.put(uriKey, map);
      return TiledMap.fromJson(map);
    }
  }

  Future<Map<String, dynamic>> _fetchTileset(String source) async {
    final uri = Uri.parse('$basePath$source');
    final uriKey = uri.toString();

    final containCache = await cache.containsKey(uriKey);

    if (containCache) {
      return cache.get(uriKey);
    } else {
      final tileSetResponse = await http.get(
        Uri.parse('$basePath$source'),
        headers: headers,
      );
      final map = jsonDecode(tileSetResponse.body) as Map<String, dynamic>;
      cache.put(uriKey, map);
      return map;
    }
  }

  Future<void> _fetchTilesetImage(String sourceBasePath, String image) async {
    var url = '$basePath$sourceBasePath$image';
    if (image.contains('http')) {
      url = image;
    }

    return _loadImage(url);
  }

  Future<void> _fetchLayerImage(MapLayer layer) async {
    if (layer is ImageLayer) {
      var url = '$basePath${layer.image}';
      if (layer.image.contains('http')) {
        url = layer.image;
      }
      return _loadImage(url);
    }
  }

  Future<void> _loadImage(String url) async {
    await _imageLoader.load(url);
  }
}
