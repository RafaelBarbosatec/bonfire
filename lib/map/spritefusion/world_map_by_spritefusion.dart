import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/spritefusion/builder/spritefusion_world_builder.dart';
import 'package:bonfire/map/spritefusion/model/spritefucion_map.dart';
import 'package:flutter/widgets.dart';

class WorldMapBySpritefusion extends WorldMap {
  late SpritefusionWorldBuilder _builder;
  WorldMapBySpritefusion(
    WorldMapReader<SpritefusionMap> reader, {
    ValueChanged<Object>? onError,
    double sizeToUpdate = 0,
    Map<String, SpritefusionObjectBuilder>? objectsBuilder,
  }) : super(const []) {
    this.sizeToUpdate = sizeToUpdate;
    _builder = SpritefusionWorldBuilder(
      reader,
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
