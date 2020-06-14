import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tile.dart';
import 'package:bonfire/tiled/tiled_world_data.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:tiledjsonreader/map/layer/object_group.dart';
import 'package:tiledjsonreader/map/layer/tile_layer.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tile_set/frame_animation.dart';
import 'package:tiledjsonreader/tile_set/tile_set.dart';
import 'package:tiledjsonreader/tile_set/tile_set_item.dart';
import 'package:tiledjsonreader/tile_set/tile_set_object.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

typedef ObjectBuilder = GameComponent Function(
    double x, double y, double width, double height);

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
  int _countObjects = 0;
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
        _countObjects++;
      }
    });
  }

  void _addTileLayer(TileLayer tileLayer) {
    int count = 0;
    tileLayer.data.forEach((tile) {
      if (tile != 0) {
        var data = getDataTile(tile);
        if (data != null) {
          if (data.animation == null) {
            _tiles.add(
              Tile.fromSpriteMultiCollision(
                data.sprite,
                Position(
                  _getX(count, tileLayer.width.toInt()),
                  _getY(count, tileLayer.width.toInt()),
                ),
                collisions: data.collisions,
                width: _tileWidth,
                height: _tileHeight,
              ),
            );
          } else {
            _tiles.add(
              Tile.fromAnimationMultiCollision(
                data.animation,
                Position(
                  _getX(count, tileLayer.width.toInt()),
                  _getY(count, tileLayer.width.toInt()),
                ),
                collisions: data.collisions,
                width: _tileWidth,
                height: _tileHeight,
              ),
            );
          }
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

      Sprite sprite = getSprite(
        '$_basePath${tileSetContain.image}',
        row,
        column,
        tileSetContain.tileWidth,
        tileSetContain.tileHeight,
      );

      FlameAnimation.Animation animation =
          getAnimation(tileSetContain, index, widthCount);

      return ItemTileSet(
        animation: animation,
        sprite: sprite,
        collisions: _getCollision(tileSetContain, index),
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
        double width = (element.width * _tileWidth) / _tileWidthOrigin;
        double height = (element.height * _tileHeight) / _tileHeightOrigin;
        var object = _objectsBuilder[element.name](x, y, width, height);

        if (object is Enemy) _enemies.add(object);
        if (object is GameDecoration)
          _decorations.add(object..additionalPriority = _countObjects);
      }
    });
  }

  Sprite getSprite(
      String image, int row, int column, double tileWidth, double tileHeight) {
    Sprite sprite = _spriteCache['$image/$row/$column'];
    if (sprite == null) {
      _spriteCache['$image/$row/$column'] = Sprite(
        image,
        x: (column * tileWidth).toDouble(),
        y: (row * tileHeight).toDouble(),
        width: tileWidth,
        height: tileHeight,
      );
    }
    return _spriteCache['$image/$row/$column'];
  }

  List<Collision> _getCollision(TileSet tileSetContain, int index) {
    List<Collision> collisions = List();
    Iterable<TileSetItem> tileSetItemList =
        tileSetContain.tiles.where((element) => element.id == (index - 1));
    if (tileSetItemList.isNotEmpty) {
      List<TileSetObject> tileSetObjectList =
          tileSetItemList.first.objectGroup.objects;
      if (tileSetObjectList.isNotEmpty) {
        tileSetObjectList.forEach((object) {
          double width = (object.width * _tileWidth) / _tileWidthOrigin;
          double height = (object.height * _tileHeight) / _tileHeightOrigin;

          double x = (object.x * _tileWidth) / _tileWidthOrigin;
          double y = (object.y * _tileHeight) / _tileHeightOrigin;

          collisions.add(Collision(
            width: width,
            height: height,
            align: Offset(x, y),
          ));
        });
        return collisions;
      }
    }
    return collisions;
  }

  FlameAnimation.Animation getAnimation(
      TileSet tileSetContain, int index, int widthCount) {
    try {
      TileSetItem tileSetItemList = tileSetContain.tiles
          .firstWhere((element) => element.id == (index - 1));
      List<FrameAnimation> animationFrames = tileSetItemList.animation;
      if (animationFrames != null || animationFrames.isNotEmpty) {
        List<Sprite> spriteList = List();
        double stepTime = animationFrames[0].duration / 1000;
        animationFrames.forEach((frame) {
          int row = _getY(frame.tileid, widthCount).toInt();
          int column = _getX(frame.tileid, widthCount).toInt();

          Sprite sprite = getSprite(
            '$_basePath${tileSetContain.image}',
            row,
            column,
            tileSetContain.tileWidth,
            tileSetContain.tileHeight,
          );
          spriteList.add(sprite);
        });

        return FlameAnimation.Animation.spriteList(spriteList,
            stepTime: stepTime);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

class ItemTileSet {
  final FlameAnimation.Animation animation;
  final Sprite sprite;
  final List<Collision> collisions;

  ItemTileSet({this.sprite, this.collisions, this.animation});
}
