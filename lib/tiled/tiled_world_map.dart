import 'dart:convert';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/map/tile/tile_with_collision.dart';
import 'package:bonfire/tiled/tiled_world_data.dart';
import 'package:bonfire/util/controlled_update_animation.dart';
import 'package:bonfire/util/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tiledjsonreader/map/layer/map_layer.dart';
import 'package:tiledjsonreader/map/layer/object_group.dart';
import 'package:tiledjsonreader/map/layer/tile_layer.dart';
import 'package:tiledjsonreader/map/tile_set_detail.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tile_set/frame_animation.dart';
import 'package:tiledjsonreader/tile_set/tile_set.dart';
import 'package:tiledjsonreader/tile_set/tile_set_item.dart';
import 'package:tiledjsonreader/tile_set/tile_set_object.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

typedef ObjectBuilder = GameComponent Function(
  double x,
  double y,
  double width,
  double height,
);

class TiledWorldMap {
  static const ORIENTATION_SUPPORTED = 'orthogonal';
  final String path;
  final Size? forceTileSize;
  final ValueChanged<Object>? onError;
  late TiledJsonReader _reader;
  List<Tile> _tiles = [];
  List<GameComponent> _components = [];
  String? _basePath;
  String _basePathFlame = 'assets/images/';
  TiledMap? _tiledMap;
  double _tileWidth = 0;
  double _tileHeight = 0;
  double _tileWidthOrigin = 0;
  double _tileHeightOrigin = 0;
  bool fromServer = false;
  Map<String, Sprite> _spriteCache = Map();
  Map<String, ControlledUpdateAnimation> _animationCache = Map();
  Map<String, ObjectBuilder> _objectsBuilder = Map();

  TiledWorldMap(
    this.path, {
    this.forceTileSize,
    this.onError,
  }) {
    _basePath = path.replaceAll(path.split('/').last, '');
    fromServer = path.contains('http://') || path.contains('https://');
    _reader = TiledJsonReader(_basePathFlame + path);
  }

  void registerObject(String name, ObjectBuilder builder) {
    _objectsBuilder[name] = builder;
  }

  Future<TiledWorldData> build() async {
    try {
      _tiledMap = await _readMap();
      if (_tiledMap?.orientation != ORIENTATION_SUPPORTED) {
        throw Exception(
          'Orientation not supported. please use $ORIENTATION_SUPPORTED orientation',
        );
      }
      _tileWidthOrigin = _tiledMap?.tileWidth?.toDouble() ?? 0.0;
      _tileHeightOrigin = _tiledMap?.tileHeight?.toDouble() ?? 0.0;
      _tileWidth = forceTileSize?.width ?? _tileWidthOrigin;
      _tileHeight = forceTileSize?.height ?? _tileHeightOrigin;
      await _load(_tiledMap!);
    } catch (e) {
      onError?.call(e);
      print('(TiledWorldMap) Error: $e');
    }

    return Future.value(TiledWorldData(
      map: MapWorld(_tiles),
      components: _components,
    ));
  }

  Future<void> _load(TiledMap tiledMap) async {
    await Future.forEach<MapLayer>(tiledMap.layers ?? [], (layer) async {
      if (layer is TileLayer) {
        await _addTileLayer(layer);
      }
      if (layer is ObjectGroup) {
        _addObjects(layer);
      }
    });
  }

  Future<void> _addTileLayer(TileLayer tileLayer) async {
    if (tileLayer.visible != true) return;
    int count = 0;
    double offsetX =
        ((tileLayer.offsetX ?? 0.0) * _tileWidth) / _tileWidthOrigin;
    double offsetY =
        ((tileLayer.offsetY ?? 0.0) * _tileHeight) / _tileHeightOrigin;
    await Future.forEach<int>(tileLayer.data ?? [], (tile) async {
      if (tile != 0) {
        var data = await _getDataTile(tile);
        if (data != null) {
          if (data.animation == null) {
            _tiles.add(
              TileWithCollision.withSprite(
                Future.value(data.sprite),
                Vector2(
                  _getX(count, tileLayer.width?.toInt() ?? 0),
                  _getY(count, tileLayer.width?.toInt() ?? 0),
                ),
                offsetX: offsetX,
                offsetY: offsetY,
                collisions: data.collisions,
                width: _tileWidth,
                height: _tileHeight,
                type: data.type,
              ),
            );
          } else {
            _tiles.add(
              TileWithCollision.withAnimation(
                data.animation!,
                Vector2(
                  _getX(count, tileLayer.width?.toInt() ?? 0),
                  _getY(count, tileLayer.width?.toInt() ?? 0),
                ),
                offsetX: offsetX,
                offsetY: offsetY,
                collisions: data.collisions,
                width: _tileWidth,
                height: _tileHeight,
                type: data.type,
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

  Future<ItemTileSet?> _getDataTile(int index) async {
    TileSet? tileSetContain;
    int firsTgId = 0;

    _tiledMap?.tileSets?.forEach(
      (tileSet) {
        if (tileSet.tileSet != null &&
            tileSet.firsTgId != null &&
            index >= tileSet.firsTgId!) {
          firsTgId = tileSet.firsTgId!;
          tileSetContain = tileSet.tileSet!;
        }
      },
    );

    if (tileSetContain != null) {
      final int widthCount =
          (tileSetContain?.imageWidth ?? 0) ~/ (tileSetContain?.tileWidth ?? 0);

      int row = _getY((index - firsTgId), widthCount).toInt();
      int column = _getX((index - firsTgId), widthCount).toInt();

      Sprite sprite = await _getSprite(
        '$_basePath${tileSetContain?.image}',
        row,
        column,
        tileSetContain?.tileWidth ?? 0,
        tileSetContain?.tileHeight ?? 0,
      );

      final animation = await _getAnimation(
        tileSetContain!,
        (index - firsTgId),
        widthCount,
      );

      DataObjectCollision object = _getCollision(
        tileSetContain!,
        (index - firsTgId),
      );

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
    if (layer.visible != true) return;
    double offsetX = ((layer.offsetX ?? 0.0) * _tileWidth) / _tileWidthOrigin;
    double offsetY = ((layer.offsetY ?? 0.0) * _tileHeight) / _tileHeightOrigin;
    layer.objects?.forEach(
      (element) {
        if (_objectsBuilder[element.name] != null) {
          double x =
              (((element.x ?? 0.0) * _tileWidth) / _tileWidthOrigin) + offsetX;
          double y = (((element.y ?? 0.0) * _tileHeight) / _tileHeightOrigin) +
              offsetY;
          double width =
              ((element.width ?? 0.0) * _tileWidth) / _tileWidthOrigin;
          double height =
              ((element.height ?? 0.0) * _tileHeight) / _tileHeightOrigin;
          final object =
              _objectsBuilder[element.name]?.call(x, y, width, height);

          if (object != null) {
            _components.add(object);
          }
        }
      },
    );
  }

  Future<Sprite> _getSprite(
    String image,
    int row,
    int column,
    double tileWidth,
    double tileHeight,
  ) async {
    if (_spriteCache.containsKey('$image/$row/$column')) {
      return Future.value(_spriteCache['$image/$row/$column']);
    }
    final spriteSheetImg = await _loadImage(image);
    _spriteCache['$image/$row/$column'] = spriteSheetImg.getSprite(
      x: (column * tileWidth).toDouble(),
      y: (row * tileHeight).toDouble(),
      width: tileWidth,
      height: tileHeight,
    );
    return Future.value(_spriteCache['$image/$row/$column']);
  }

  DataObjectCollision _getCollision(TileSet tileSetContain, int index) {
    Iterable<TileSetItem> tileSetItemList = tileSetContain.tiles?.where(
          (element) => element.id == index,
        ) ??
        [];

    if ((tileSetItemList.isNotEmpty)) {
      List<TileSetObject> tileSetObjectList =
          tileSetItemList.first.objectGroup?.objects ?? [];

      String type = tileSetItemList.first.type ?? '';

      List<CollisionArea> collisions = [];

      if (tileSetObjectList.isNotEmpty) {
        tileSetObjectList.forEach((object) {
          double width =
              ((object.width ?? 0.0) * _tileWidth) / _tileWidthOrigin;
          double height =
              ((object.height ?? 0.0) * _tileHeight) / _tileHeightOrigin;

          double x = ((object.x ?? 0.0) * _tileWidth) / _tileWidthOrigin;
          double y = ((object.y ?? 0.0) * _tileHeight) / _tileHeightOrigin;

          CollisionArea ca = CollisionArea.rectangle(
            size: Size(width, height),
            align: Vector2(x, y),
          );

          if (object.ellipse == true) {
            ca = CollisionArea.circle(
              radius: (width > height ? width : height) / 2,
              align: Vector2(x, y),
            );
          }

          if (object.polygon?.isNotEmpty == true) {
            double? minorX;
            double? minorY;
            List<Vector2> points = object.polygon!.map((e) {
              Vector2 vector = Vector2(
                ((e.x ?? 0.0) * _tileWidth) / _tileWidthOrigin,
                ((e.y ?? 0.0) * _tileHeight) / _tileHeightOrigin,
              );

              if (minorX == null) {
                minorX = vector.x;
              } else if (vector.x < (minorX ?? 0.0)) {
                minorX = vector.x;
              }

              if (minorY == null) {
                minorY = vector.y;
              } else if (vector.y < (minorY ?? 0.0)) {
                minorY = vector.y;
              }
              return vector;
            }).toList();

            if ((minorX ?? 0) < 0) {
              points = points.map((e) {
                return Vector2(e.x - minorX!, e.y);
              }).toList();
            }

            if ((minorY ?? 0) < 0) {
              points = points.map((e) {
                return Vector2(e.x, e.y - minorY!);
              }).toList();
            }

            double xAlign = x - points.first.x;
            double yAlign = y - points.first.y;

            ca = CollisionArea.polygon(
              points: points,
              align: Vector2(xAlign, yAlign),
            );
          }

          collisions.add(ca);
        });
      }
      return DataObjectCollision(collisions: collisions, type: type);
    }
    return DataObjectCollision();
  }

  Future<ControlledUpdateAnimation?> _getAnimation(
    TileSet tileSetContain,
    int index,
    int widthCount,
  ) async {
    try {
      TileSetItem tileSetItemList = tileSetContain.tiles!.firstWhere(
        (element) => element.id == index,
      );

      List<FrameAnimation> animationFrames = tileSetItemList.animation ?? [];

      if ((animationFrames.isNotEmpty)) {
        String animationKey = '${tileSetContain.name}/$index';
        if (_animationCache.containsKey(animationKey)) {
          return Future.value(_animationCache[animationKey]);
        }
        List<Sprite> spriteList = [];
        double stepTime = (animationFrames[0].duration ?? 100) / 1000;
        await Future.forEach<FrameAnimation>(animationFrames, (frame) async {
          int row = _getY((frame.tileid ?? 0), widthCount).toInt();
          int column = _getX((frame.tileid ?? 0), widthCount).toInt();

          Sprite sprite = await _getSprite(
            '$_basePath${tileSetContain.image}',
            row,
            column,
            tileSetContain.tileWidth ?? 0.0,
            tileSetContain.tileHeight ?? 0.0,
          );
          spriteList.add(sprite);
        });

        _animationCache[animationKey] = ControlledUpdateAnimation(
          Future.value(
            SpriteAnimation.spriteList(
              spriteList,
              stepTime: stepTime,
            ),
          ),
        );

        return _animationCache[animationKey];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<TiledMap> _readMap() async {
    if (fromServer) {
      try {
        TiledMap tiledMap;
        final mapResponse = await http.get(Uri.parse(path));
        tiledMap = TiledMap.fromJson(jsonDecode(mapResponse.body));
        await Future.forEach<TileSetDetail>(tiledMap.tileSets ?? [],
            (tileSet) async {
          if (tileSet.source?.contains('.json') == false) {
            throw Exception('Invalid TileSet source: only supports json files');
          }
          final tileSetResponse = await http.get(
            Uri.parse('$_basePath${tileSet.source}'),
          );
          Map<String, dynamic> _result = jsonDecode(tileSetResponse.body);
          tileSet.tileSet = TileSet.fromJson(_result);
        });
        return Future.value(tiledMap);
      } catch (e) {
        print('(TiledWorldMap) Error: $e');
        return Future.value(TiledMap());
      }
    } else {
      return _reader.read();
    }
  }

  Future<Image> _loadImage(String image) async {
    if (fromServer) {
      final imageCache = getImageFromCache(image);
      if (imageCache != null) {
        return imageCache;
      }
      final response = await http.get(Uri.parse(image));
      String img64 = base64Encode(response.bodyBytes);
      return Flame.images.fromBase64(image, img64);
    } else {
      return Flame.images.load(image);
    }
  }

  Image? getImageFromCache(String image) {
    try {
      return Flame.images.fromCache(image);
    } catch (e) {
      return null;
    }
  }
}

class ItemTileSet {
  final ControlledUpdateAnimation? animation;
  final Sprite? sprite;
  final List<CollisionArea>? collisions;
  final String? type;

  ItemTileSet({
    this.sprite,
    this.collisions,
    this.animation,
    this.type,
  });
}

class DataObjectCollision {
  final List<CollisionArea>? collisions;
  final String type;

  DataObjectCollision({this.collisions, this.type = ''});
}
