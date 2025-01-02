import 'package:bonfire/map/spritefusion/model/spritefucion_map.dart';
import 'package:bonfire/map/util/world_map_reader.dart';
import 'package:flutter/services.dart';

class SpritefusionAssetReader extends WorldMapReader<SpritefusionMap> {
  static const _assetPrefixKey = 'assets/images/';
  final String asset;
  String _path = '';

  @override
  late String basePath;

  SpritefusionAssetReader({
    required this.asset,
  }) {
    final assetKey = asset.startsWith(_assetPrefixKey)
        ? asset.substring(_assetPrefixKey.length)
        : asset;
    basePath = assetKey.replaceAll(assetKey.split('/').last, '');
    _path = '$_assetPrefixKey$assetKey';
  }

  @override
  Future<SpritefusionMap> readMap() async {
    final data = await rootBundle.loadString(_path);
    return SpritefusionMap.fromJson(data)
      ..imgPath = '${basePath}spritesheet.png';
  }
}
