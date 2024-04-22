import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/base/layer.dart';
import 'package:bonfire/map/spritefusion/model/spritefucion_map.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';
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

  Future<void> _load(SpritefusionMap map) async {
    int index = 0;
    final spritesheet = await MapAssetsManager.loadImage(map.imgPath);
    final maxRow = spritesheet.width / map.tileSize;
    for (var layer in map.layers.reversed) {
      List<Tile> tiles = _loadTiles(
        layer.tiles,
        map.tileSize,
        map.imgPath,
        maxRow,
        layer.collider,
      );
      _layers.add(
        Layer(
          id: index,
          tiles: tiles,
          priority: index,
        ),
      );
      index++;
    }
  }

  List<Tile> _loadTiles(
    List<SpritefusionMapLayerTile> tiles,
    double tileSize,
    String imgPath,
    double maxRow,
    bool collider,
  ) {
    final size = Vector2.all(tileSize);
    return tiles.map(
      (tile) {
        int row = tile.idInt ~/ maxRow;
        int col = (tile.idInt % maxRow).toInt();
        return Tile(
          x: tile.x.toDouble(),
          y: tile.y.toDouble(),
          width: tileSize,
          height: tileSize,
          sprite: TileSprite(
            path: imgPath,
            position: Vector2(col.toDouble(), row.toDouble()),
            size: size,
          ),
          collisions: collider ? [RectangleHitbox(size: size)] : null,
        );
      },
    ).toList();
  }
}
