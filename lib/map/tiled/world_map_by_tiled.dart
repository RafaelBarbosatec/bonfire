import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';

class WorldMapByTiled extends WorldMap {
  late TiledWorldBuilder _builder;
  WorldMapByTiled(
    WorldMapReader<TiledMap> reader, {
    Vector2? forceTileSize,
    ValueChanged<Object>? onError,
    double sizeToUpdate = 0,
    Map<String, ObjectBuilder>? objectsBuilder,
  }) : super(const []) {
    this.sizeToUpdate = sizeToUpdate;
    _builder = TiledWorldBuilder(
      reader,
      forceTileSize: forceTileSize,
      onError: onError,
      sizeToUpdate: sizeToUpdate,
      objectsBuilder: objectsBuilder,
    );
  }

  @override
  Future<void> onLoad() async {
    final map = await _builder.build();
    layers = map.map.layers;
    gameRef.addAll(map.components ?? []);
    return super.onLoad();
  }
}
