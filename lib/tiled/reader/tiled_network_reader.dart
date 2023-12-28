import 'dart:convert';

import 'package:bonfire/tiled/reader/tiled_reader.dart';
import 'package:http/http.dart' as http;
import 'package:tiledjsonreader/map/tile_set_detail.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';

class TiledNetworkReader extends TiledReader {
// ignore: constant_identifier_names
  static const ORIENTATION_SUPPORTED = 'orthogonal';
  final Uri uri;
  @override
  late String basePath;

  TiledNetworkReader({required this.uri}) {
    String url = uri.toString();
    basePath = url.replaceAll(url.split('/').last, '');
  }

  @override
  Future<TiledMap> readMap() async {
    try {
      final mapResponse = await http.get(uri);
      TiledMap tiledMap = TiledMap.fromJson(jsonDecode(mapResponse.body));
      await Future.forEach<TileSetDetail>(
        tiledMap.tileSets ?? [],
        _fillTileSet,
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

  Future _fillTileSet(TileSetDetail tileSet) async {
    if (tileSet.source != null) {
      if (!_isSuppotedFileType(tileSet.source!)) {
        throw Exception('Invalid TileSet source: only supports json files');
      }
      final tileSetResponse = await http.get(
        Uri.parse('$basePath${tileSet.source}'),
      );
      tileSet.updateFromMap(jsonDecode(tileSetResponse.body));
    }
    return null;
  }

  bool _isSuppotedFileType(String source) {
    return (source.contains('.json') || source.contains('.tsj'));
  }
}
