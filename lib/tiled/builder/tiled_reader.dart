import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tiledjsonreader/map/tile_set_detail.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

class TiledReader {
  // ignore: constant_identifier_names
  static const ORIENTATION_SUPPORTED = 'orthogonal';
  final String path;
  late bool _fromServer;
  late String _basePath;
  late TiledJsonReader _reader;

  TiledReader(this.path) {
    _fromServer = path.contains('http');
    _basePath = path.replaceAll(path.split('/').last, '');
    _reader = TiledJsonReader('assets/images/$path');
  }

  Future<TiledMap> readMap() async {
    if (_fromServer) {
      try {
        final mapResponse = await http.get(Uri.parse(path));
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
    } else {
      return _reader.read();
    }
  }

  FutureOr _fillTileSet(TileSetDetail tileSet) async {
    if (tileSet.source != null) {
      if (!_isSuppotedFileType(tileSet.source!)) {
        throw Exception('Invalid TileSet source: only supports json files');
      }
      final tileSetResponse = await http.get(
        Uri.parse('$_basePath${tileSet.source}'),
      );
      tileSet.updateFromMap(jsonDecode(tileSetResponse.body));
    }
  }

  bool _isSuppotedFileType(String source) {
    return (source.contains('.json') || source.contains('.tsj'));
  }
}
