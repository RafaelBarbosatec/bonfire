import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/base/layer.dart';
import 'package:bonfire/map/spritefusion/model/spritefucion_map.dart';
import 'package:bonfire/map/tiled/model/tiled_world_data.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';
import 'package:flutter/material.dart';

typedef SpritefusionObjectBuilder = GameComponent Function(
  Vector2 position,
);

class SpritefusionWorldBuilder {
  final ValueChanged<Object>? onError;
  final WorldMapReader<SpritefusionMap> reader;
  final double sizeToUpdate;
  final List<Layer> _layers = [];
  final List<GameComponent> components = [];
  final Map<String, SpritefusionObjectBuilder>? objectsBuilder;

  SpritefusionWorldBuilder(
    this.reader, {
    required this.onError,
    this.sizeToUpdate = 0,
    this.objectsBuilder,
  });

  Future<WorldBuildData> build() async {
    try {
      final map = await reader.readMap();
      await _load(map);
    } catch (e) {
      onError?.call(e);
      // ignore: avoid_print
      print('(SpritefusionWorldBuilder) Error: $e');
      rethrow;
    }

    return Future.value(
      WorldBuildData(
        map: WorldMap(
          _layers,
          tileSizeToUpdate: sizeToUpdate,
        ),
        components: components,
      ),
    );
  }

  Future<void> _load(SpritefusionMap map) async {
    var index = 0;
    final spritesheet = await MapAssetsManager.loadImage(map.imgPath);
    final maxRow = spritesheet.width / map.tileSize;
    for (final layer in map.layers.reversed) {
      final objectBuilder = objectsBuilder?[layer.name];
      if (objectBuilder != null) {
        _addObjects(layer, objectBuilder, map.tileSize);
      } else {
        _addTile(layer, map, maxRow, index);
      }
      index++;
    }
  }

  void _addTile(
    SpritefusionMapLayer layer,
    SpritefusionMap map,
    double maxRow,
    int index,
  ) {
    final tiles = _loadTiles(
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
        final row = tile.idInt ~/ maxRow;
        final col = (tile.idInt % maxRow).toInt();
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

  void _addObjects(
    SpritefusionMapLayer layer,
    SpritefusionObjectBuilder objectBuilder,
    double tileSize,
  ) {
    for (final tile in layer.tiles) {
      final position = Vector2(
            tile.x.toDouble(),
            tile.y.toDouble(),
          ) *
          tileSize;
      components.add(objectBuilder(position));
    }
  }
}
