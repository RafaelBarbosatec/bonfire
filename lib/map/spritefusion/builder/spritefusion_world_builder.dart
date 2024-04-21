import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/spritefusion/model/spritefucion_map.dart';
import 'package:bonfire/map/spritefusion/model/spritefusion_layer.dart';
import 'package:flutter/material.dart';

class SpritefusionWorldBuilder {
  final ValueChanged<Object>? onError;
  final WorldMapReader<SpritefusionMap> reader;
  final double sizeToUpdate;
  final List<SpritefusionLayer> _layers = [];

  SpritefusionWorldBuilder(
    this.reader, {
    required this.onError,
    this.sizeToUpdate = 0,
  });

  Future<WorldMap> build() async {
    try {
      final tiledMap = await reader.readMap();
      print(tiledMap.layers.length);
      // await _load(_tiledMap!);
    } catch (e) {
      onError?.call(e);
      // ignore: avoid_print
      print('(SpritefusionWorldBuilder) Error: $e');
    }

    return Future.value(
      WorldMap(
        _layers
            .map((e) => TileLayerComponent.fromSpritefusionLayer(e))
            .toList(),
        tileSizeToUpdate: sizeToUpdate,
      ),
    );
  }
}
