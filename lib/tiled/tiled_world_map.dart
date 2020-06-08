import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tile.dart';
import 'package:bonfire/tiled/tiled_world_data.dart';
import 'package:flame/sprite.dart';
import 'package:tiledjsonreader/map/layer/object_group.dart';
import 'package:tiledjsonreader/map/layer/tile_layer.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tile_set/tile_set.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

class TiledWorldMap {
  final String pathFile;
  final int tileSize;
  TiledJsonReader _reader;
  List<Tile> _tiles = List();
  String _basePath;
  String _basePathFlame = 'assets/images/';
  TiledMap _tiledMap;
  SpriteSheet spriteSheet;

  TiledWorldMap(this.pathFile, {this.tileSize}) {
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
        var data = getDataTile(element);
        if (data != null) {
          _tiles.add(
            Tile.fromSprite(
              data.sprite,
              Position(
                _getX(count, tileLayer.width.toInt()) * _tiledMap.tileWidth,
                _getY(count, tileLayer.width.toInt()) * _tiledMap.tileHeight,
              ),
              collision: data.collision,
              size: data.size,
            ),
          );
        }
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

  ItemTileSet getDataTile(int index) {
    TileSet tileSetContain;
    _tiledMap.tileSets.forEach((tileSet) {
      if (tileSet.tileSet != null && index <= tileSet.tileSet.tileCount) {
        tileSetContain = tileSet.tileSet;
      }
    });

    if (tileSetContain != null) {
      if (spriteSheet == null)
        spriteSheet = SpriteSheet(
          imageName:
              '${_basePath.replaceAll(_basePathFlame, '')}${tileSetContain.image}',
          textureWidth: tileSetContain.tileWidth.toInt(),
          textureHeight: tileSetContain.tileHeight.toInt(),
          columns: tileSetContain.columns,
          rows: tileSetContain.tileCount ~/ tileSetContain.columns,
        );

      final int widthCount =
          tileSetContain.imageWidth ~/ tileSetContain.tileWidth;

      print(index);
      int row = _getY(index, widthCount).toInt();
      int columm = _getX(index, widthCount).toInt();
      print('$row / $columm');
      return ItemTileSet(
        sprite: spriteSheet.getSprite(
          row,
          columm,
        ),
        collision: tileSetContain.tiles
            .where((element) => element.id == index)
            .isNotEmpty,
        size: tileSetContain.tileWidth,
      );
    } else {
      return null;
    }
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

class ItemTileSet {
  final Sprite sprite;
  final bool collision;
  final double size;

  ItemTileSet({this.sprite, this.collision = false, this.size});
}
