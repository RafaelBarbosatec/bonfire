import 'package:bonfire/map/util/world_map_reader.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

class TiledAssetReader extends WorldMapReader<TiledMap> {
// ignore: constant_identifier_names
  static const _ASSET_KEY_PREFIX = 'assets/images/';
  final String asset;
  late TiledJsonReader _reader;
  @override
  late String basePath;

  TiledAssetReader({
    required this.asset,
  }) {
    final assetKey = asset.startsWith(_ASSET_KEY_PREFIX)
        ? asset.substring(_ASSET_KEY_PREFIX.length)
        : asset;
    basePath = assetKey.replaceAll(assetKey.split('/').last, '');
    _reader = TiledJsonReader('assets/images/$assetKey');
  }

  @override
  Future<TiledMap> readMap() async {
    return _reader.read();
  }
}
