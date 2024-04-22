import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/base/layer.dart';
import 'package:bonfire/map/spritefusion/model/spritefucion_map.dart';
import 'package:flutter/material.dart';

class SpritefusionWorldBuilder {
  final ValueChanged<Object>? onError;
  final WorldMapReader<SpritefusionMap> reader;
  final double sizeToUpdate;
  final List<Layer> _layers = [];

  SpritefusionWorldBuilder(
    this.reader, {
    required this.onError,
    this.sizeToUpdate = 0,
  });

  Future<WorldMap> build() async {
    try {
      final map = await reader.readMap();
      await _load(map);
    } catch (e) {
      onError?.call(e);
      // ignore: avoid_print
      print('(SpritefusionWorldBuilder) Error: $e');
    }

    return Future.value(
      WorldMap(
        _layers,
        tileSizeToUpdate: sizeToUpdate,
      ),
    );
  }

  Future<void> _load(SpritefusionMap map) async {}
}
