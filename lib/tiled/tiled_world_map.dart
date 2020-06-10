import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tile.dart';
import 'package:bonfire/tiled/tiled_world_data.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:tiledjsonreader/map/layer/object_group.dart';
import 'package:tiledjsonreader/map/layer/tile_layer.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tile_set/tile_set.dart';
import 'package:tiledjsonreader/tile_set/tile_set_item.dart';
import 'package:tiledjsonreader/tile_set/tile_set_object.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

typedef ObjectBuilder = GameComponent Function(double x, double y);

class TiledWorldMap {
  final String pathFile;
  final double forceTileSize;
  TiledJsonReader _reader;
  List<Tile> _tiles = List();
  List<Enemy> _enemies = List();
  List<GameDecoration> _decorations = List();
  String _basePath;
  String _basePathFlame = 'assets/images/';
  TiledMap _tiledMap;
  double _tileWidth;
  double _tileHeight;
  double _tileWidthOrigin;
  double _tileHeightOrigin;
  Map<String, Sprite> _spriteCache = Map();
  Map<String, ObjectBuilder> _objectsBuilder = Map();

  TiledWorldMap(this.pathFile, {this.forceTileSize}) {
    _basePath = pathFile.replaceAll(pathFile.split('/').last, '');
    _reader = TiledJsonReader(_basePathFlame + pathFile);
  }

  void registerObject(String name, ObjectBuilder builder) {
    _objectsBuilder[name] = builder;
  }

  Future<TiledWorldData> build() async {
    _tiledMap = await _reader.read();
    _tileWidthOrigin = _tiledMap.tileWidth.toDouble();
    _tileHeightOrigin = _tiledMap.tileHeight.toDouble();
    _tileWidth = forceTileSize ?? _tileWidthOrigin;
    _tileHeight = forceTileSize ?? _tileHeightOrigin;
    _load(_tiledMap);
    return Future.value(TiledWorldData(
      map: MapWorld(_tiles),
      decorations: _decorations,
      enemies: _enemies,
    ));
  }

  void _load(TiledMap tiledMap) {
    tiledMap.layers.forEach((layer) {
      if (layer is TileLayer) {
        _addTileLayer(layer);
      }
      if (layer is ObjectGroup) {
        _addObjects(layer);
      }
    });
  }

  void _addTileLayer(TileLayer tileLayer) {
    int count = 0;
    tileLayer.data.forEach((tile) {
      if (tile != 0) {
        var data = getDataTile(tile);
        if (data != null) {
          _tiles.add(
            Tile.fromSprite(
              data.sprite,
              Position(
                _getX(count, tileLayer.width.toInt()),
                _getY(count, tileLayer.width.toInt()),
              ),
              collision: data.collision,
              width: _tileWidth,
              height: _tileHeight,
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
    return (index / width).floor().toDouble();
  }

  ItemTileSet getDataTile(int index) {
    TileSet tileSetContain;
    _tiledMap.tileSets.forEach((tileSet) {
      if (tileSet.tileSet != null && index <= tileSet.tileSet.tileCount) {
        tileSetContain = tileSet.tileSet;
      }
    });

    if (tileSetContain != null) {
      final int widthCount =
          tileSetContain.imageWidth ~/ tileSetContain.tileWidth;

      int row = _getY(index - 1, widthCount).toInt();
      int column = _getX(index - 1, widthCount).toInt();

      Sprite sprite = _spriteCache['${tileSetContain.image}/$row/$column'];
      if (sprite == null) {
        sprite = getSprite(
          '$_basePath${tileSetContain.image}',
          row,
          column,
          tileSetContain.tileWidth,
          tileSetContain.tileHeight,
        );
        _spriteCache['${tileSetContain.image}/$row/$column'] = sprite;
      }

      Collision collision = _getCollision(tileSetContain, index);

      return ItemTileSet(
        sprite: sprite,
        width: tileSetContain.tileWidth,
        height: tileSetContain.tileHeight,
        collision: collision,
      );
    } else {
      return null;
    }
  }

  void _addObjects(ObjectGroup layer) {
    layer.objects.forEach((element) {
      if (_objectsBuilder[element.name] != null) {
        double x = (element.x * _tileWidth) / _tileWidthOrigin;
        double y = (element.y * _tileHeight) / _tileHeightOrigin;
        var object = _objectsBuilder[element.name](x, y);

        if (object is Enemy) _enemies.add(object);
        if (object is GameDecoration) _decorations.add(object);
      }
    });
  }

  Sprite getSprite(
      String image, int row, int column, double tileWidth, double tileHeight) {
    return Sprite(
      image,
      x: (column * tileWidth).toDouble(),
      y: (row * tileHeight).toDouble(),
      width: tileWidth,
      height: tileHeight,
    );
  }

  Collision _getCollision(TileSet tileSetContain, int index) {
    try {
      TileSetItem tileSetItemList = tileSetContain.tiles
          .firstWhere((element) => element.id == (index - 1));
      List<TileSetObject> tileSetObjectList =
          tileSetItemList.objectGroup.objects;
      if (tileSetObjectList.isNotEmpty) {
        double width =
            (tileSetObjectList[0].width * _tileWidth) / _tileWidthOrigin;
        double height =
            (tileSetObjectList[0].height * _tileHeight) / _tileHeightOrigin;

        double x = (tileSetObjectList[0].x * _tileWidth) / _tileWidthOrigin;
        double y = (tileSetObjectList[0].y * _tileHeight) / _tileHeightOrigin;
        return Collision(
          width: width,
          height: height,
          align: Offset(x, y),
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

class ItemTileSet {
  final Sprite sprite;
  final Collision collision;
  final double width;
  final double height;

  ItemTileSet({this.sprite, this.collision, this.width, this.height});
}
