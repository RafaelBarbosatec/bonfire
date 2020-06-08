import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tile.dart';
import 'package:bonfire/tiled/tiled_world_data.dart';
import 'package:flame/sprite.dart';
import 'package:tiledjsonreader/map/layer/object_group.dart';
import 'package:tiledjsonreader/map/layer/tile_layer.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

class TiledWorldMap {
  final String pathFile;
  final int tileSize;
  TiledJsonReader _reader;
  List<Tile> _tiles;
  String _basePath;
  String _basePathFlame = 'assets/images/';
  TiledMap _tiledMap;

  TiledWorldMap(this.pathFile, this.tileSize) {
    _basePath = pathFile.replaceAll(pathFile.split('/').last, '');
    _reader = TiledJsonReader(pathFile);
  }

  Future<TiledWorldData> build() async {
    _tiledMap = await _reader.read();
    _load(_tiledMap);
    return Future.value(TiledWorldData(
      map: MapWorld(_tiles),
      decorations: [],
      enemies: [],
    ));
  }

  void _load(TiledMap tiledMap) {
    tiledMap.layers.forEach((layer) {
      if (layer is TileLayer) {
        addTileLayer(layer);
      }
      if (layer is ObjectGroup) {
        addObjects(layer);
      }
    });
  }

  void addTileLayer(TileLayer tileLayer) {
    int count = 0;
    tileLayer.data.forEach((element) {
      if (element != 0) {
        _tiles.add(
          Tile.fromSprite(
            getSprite(element),
            Position(
              _getX(count, tileLayer.width.toInt()) * _tiledMap.tileWidth,
              _getY(count, tileLayer.width.toInt()) * _tiledMap.tileHeight,
            ),
          ),
        );
      }
      count++;
    });
  }

  double _getX(int index, int width) {
    return (index % width).toDouble();
  }

  double _getY(int index, int width) {
    return index / width;
  }

  Sprite getSprite(int index) {
    return Sprite('');
  }

  void addObjects(ObjectGroup layer) {}

//  void _loadTileSets(TiledMap tiledMap) {
//    tiledMap.tileSets.forEach((tileSet){
//      final spriteSheet = SpriteSheet(
//        imageName: '${_basePath.replaceAll(_basePathFlame, '')}${tileSet.tileSet.image}',
//        textureWidth: tileSet.tileSet.tileWidth.toInt(),
//        textureHeight: tileSet.tileSet.tileHeight.toInt(),
//        columns: tileSet.tileSet.columns,
//        rows: tileSet.tileSet.tileCount ~/ tileSet.tileSet.columns,
//      );
//
//      _tiles.add(Tile.fromSprite(spriteSheet.getSprite(row, column), position))
//
//    });
//  }
}
