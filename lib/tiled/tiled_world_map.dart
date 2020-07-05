import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tile.dart';
import 'package:bonfire/tiled/tiled_world_data.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/sprite.dart';
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
  static const TYPE_TILE_ABOVE = 'above';

  final String pathFile;
  final double forceTileSize;
  TiledJsonReader _reader;
  List<Tile> _tiles = List();
  List<GameComponent> _components = List();
  String _basePath;
  String _basePathFlame = 'assets/images/';
  TiledMap _tiledMap;
  double _tileWidth;
  double _tileHeight;
  double _tileWidthOrigin;
  double _tileHeightOrigin;
  int _countObjects = 0;
  Map<String, Sprite> _spriteCache = Map();
  Map<String, Image> _imageCache = Map();
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
    await _load(_tiledMap);
    return Future.value(TiledWorldData(
      map: MapWorld(_tiles),
      components: _components,
    ));
  }

  Future<void> _load(TiledMap tiledMap) async {
    await Future.forEach(tiledMap.layers, (layer) async {
      if (layer is TileLayer) {
        await _addTileLayer(layer);
      }
      if (layer is ObjectGroup) {
        _addObjects(layer);
        _countObjects++;
      }
    });
  }

  Future<void> _addTileLayer(TileLayer tileLayer) async {
    int count = 0;
    await Future.forEach(tileLayer.data, (tile) async {
      if (tile != 0) {
        var data = await getDataTile(tile);
        if (data != null) {
          if (data.animation == null) {
            if (data.type.toLowerCase() == TYPE_TILE_ABOVE) {
              _components.add(
                GameDecoration.spriteMultiCollision(
                  data.sprite,
                  initPosition: Position(
                    _getX(count, tileLayer.width.toInt()) * _tileWidth,
                    _getY(count, tileLayer.width.toInt()) * _tileHeight,
                  ),
                  height: _tileHeight,
                  width: _tileWidth,
                  collisions: data.collisions,
                  frontFromPlayer: true,
                ),
              );
            } else {
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
            }
          } else {
            if (data.type.toLowerCase() == TYPE_TILE_ABOVE) {
              _components.add(
                GameDecoration.animationMultiCollision(data.animation,
                    initPosition: Position(
                      _getX(count, tileLayer.width.toInt()) * _tileWidth,
                      _getY(count, tileLayer.width.toInt()) * _tileHeight,
                    ),
                    height: _tileHeight,
                    width: _tileWidth,
                    collisions: data.collisions,
                    frontFromPlayer: true),
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

  Future<ItemTileSet> getDataTile(int index) async {
    TileSet tileSetContain;
    _tiledMap.tileSets.forEach(
      (tileSet) {
        if (tileSet.tileSet != null && index <= tileSet.tileSet.tileCount) {
          tileSetContain = tileSet.tileSet;
        }
      },
    );

    if (tileSetContain != null) {
      final int widthCount =
          tileSetContain.imageWidth ~/ tileSetContain.tileWidth;

      int row = _getY(index - 1, widthCount).toInt();
      int column = _getX(index - 1, widthCount).toInt();

      Sprite sprite = await getSprite(
        '$_basePath${tileSetContain.image}',
        row,
        column,
        tileSetContain.tileWidth,
        tileSetContain.tileHeight,
      );

      FlameAnimation.Animation animation = await getAnimation(
        tileSetContain,
        index,
        widthCount,
      );

      DataObjectCollision object = _getCollision(tileSetContain, index);

      return Future.value(
        ItemTileSet(
          animation: animation,
          sprite: sprite,
          type: object.type,
          collisions: object.collisions,
        ),
      );
    } else {
      return null;
    }
  }

  void _addObjects(ObjectGroup layer) {
    layer.objects.forEach(
      (element) {
        if (_objectsBuilder[element.name] != null) {
          double x = (element.x * _tileWidth) / _tileWidthOrigin;
          double y = (element.y * _tileHeight) / _tileHeightOrigin;
          double width = (element.width * _tileWidth) / _tileWidthOrigin;
          double height = (element.height * _tileHeight) / _tileHeightOrigin;
          var object = _objectsBuilder[element.name](x, y, width, height);

          if (object is GameDecoration) {
            _components.add(object..additionalPriority = _countObjects);
          } else {
            _components.add(object);
          }
        }
      },
    );
  }

  Future<Sprite> getSprite(
    String image,
    int row,
    int column,
    double tileWidth,
    double tileHeight,
  ) async {
    Image imageData = _imageCache[image];
    if (imageData == null) {
      _imageCache[image] = await Flame.images.load(image);
    }
    Sprite sprite = _spriteCache['$image/$row/$column'];
    if (sprite == null) {
      sprite = _spriteCache['$image/$row/$column'] = Sprite.fromImage(
        _imageCache[image],
        x: (column * tileWidth).toDouble(),
        y: (row * tileHeight).toDouble(),
        width: tileWidth,
        height: tileHeight,
      );
    }
    return Future.value(_spriteCache['$image/$row/$column']);
  }

  DataObjectCollision _getCollision(TileSet tileSetContain, int index) {
    Iterable<TileSetItem> tileSetItemList =
        tileSetContain?.tiles?.where((element) => element.id == (index - 1));

    if ((tileSetItemList?.isNotEmpty ?? false)) {
      List<TileSetObject> tileSetObjectList =
          tileSetItemList.first.objectGroup?.objects ?? [];

      String type = tileSetItemList.first?.type ?? '';

      List<Collision> collisions = List();

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
      }
      return DataObjectCollision(collisions: collisions, type: type);
    }
    return DataObjectCollision();
  }

  Future<FlameAnimation.Animation> getAnimation(
    TileSet tileSetContain,
    int index,
    int widthCount,
  ) async {
    try {
      TileSetItem tileSetItemList = tileSetContain.tiles
          .firstWhere((element) => element.id == (index - 1));

      List<FrameAnimation> animationFrames = tileSetItemList.animation;

      if ((animationFrames?.isNotEmpty ?? false)) {
        List<Sprite> spriteList = List();
        double stepTime = animationFrames[0].duration / 1000;
        await Future.forEach(animationFrames, (frame) async {
          int row = _getY(frame.tileid, widthCount).toInt();
          int column = _getX(frame.tileid, widthCount).toInt();

          Sprite sprite = await getSprite(
            '$_basePath${tileSetContain.image}',
            row,
            column,
            tileSetContain.tileWidth,
            tileSetContain.tileHeight,
          );
          spriteList.add(sprite);
        });

        return Future.value(
          FlameAnimation.Animation.spriteList(
            spriteList,
            stepTime: stepTime,
          ),
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
  final FlameAnimation.Animation animation;
  final Sprite sprite;
  final List<Collision> collisions;
  final String type;

  ItemTileSet({
    this.sprite,
    this.collisions,
    this.animation,
    this.type,
  });
}

class DataObjectCollision {
  final List<Collision> collisions;
  final String type;

  DataObjectCollision({this.collisions, this.type = ''});
}
