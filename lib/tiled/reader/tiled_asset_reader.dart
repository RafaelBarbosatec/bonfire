import 'package:bonfire/tiled/reader/tiled_reader.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

class TiledAssetReader extends TiledReader {
// ignore: constant_identifier_names
  static const ORIENTATION_SUPPORTED = 'orthogonal';
  final String asset;
  late TiledJsonReader _reader;
  @override
  late String basePath;

  TiledAssetReader({
    required this.asset,
  }) {
    basePath = asset.replaceAll(asset.split('/').last, '');
    _reader = TiledJsonReader('assets/images/$asset');
  }

  @override
  Future<TiledMap> readMap() async {
    return _reader.read();
  }
}
