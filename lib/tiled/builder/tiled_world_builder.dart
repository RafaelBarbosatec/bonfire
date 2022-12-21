// ignore_for_file: constant_identifier_names

import 'dart:ui';

import 'package:bonfire/background/background_image_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/tiled/builder/tiled_reader.dart';
import 'package:bonfire/tiled/model/tiled_world_data.dart';
import 'package:bonfire/util/collision_game_component.dart';
import 'package:bonfire/util/text_game_component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:tiledjsonreader/map/layer/group_layer.dart';
import 'package:tiledjsonreader/map/layer/image_layer.dart';
import 'package:tiledjsonreader/map/layer/map_layer.dart';
import 'package:tiledjsonreader/map/layer/object_layer.dart';
import 'package:tiledjsonreader/map/layer/objects.dart';
import 'package:tiledjsonreader/map/layer/tile_layer.dart';
import 'package:tiledjsonreader/map/tile_set_detail.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tile_set/frame_animation.dart';
import 'package:tiledjsonreader/tile_set/polygon.dart';
import 'package:tiledjsonreader/tile_set/tile_set_item.dart';
import 'package:tiledjsonreader/tile_set/tile_set_object.dart';

import '../model/tiled_data_object_collision.dart';
import '../model/tiled_item_tile_set.dart';

typedef ObjectBuilder = GameComponent Function(
  TiledObjectProperties properties,
);

class TiledWorldBuilder {
  static const ABOVE_TYPE = 'above';
  static const DYNAMIC_ABOVE_TYPE = 'dynamicAbove';
  static const GIT_ROTATE_180 = 3221225472;
  static const GIT_ROTATE_90 = 2684354560;
  static const GIT_ROTATE_270 = 1610612736;
  static const GIT_FLIP_HORIZONTAL = 2147483648;
  static const GIT_FLIP_VERTICAL = 1073741824;
  static const GIT_FLIP_HORIZONTAL_270 = 536870912;
  static const GIT_FLIP_HORIZONTAL_90 = 3758096384;
  final String path;
  final Vector2? forceTileSize;
  final ValueChanged<Object>? onError;
  late TiledReader _reader;
  final double tileSizeToUpdate;
  final List<TileModel> _tiles = [];
  final List<GameComponent> _components = [];
  String? _basePath;
  TiledMap? _tiledMap;
  double _tileWidth = 0;
  double _tileHeight = 0;
  double _tileWidthOrigin = 0;
  double _tileHeightOrigin = 0;
  Map<String, ObjectBuilder> _objectsBuilder = {};
  final Map<String, TileModelSprite> _tileModelSpriteCache = {};
  int countTileLayer = 0;
  int countImageLayer = 0;

  TiledWorldBuilder(
    this.path, {
    this.forceTileSize,
    this.onError,
    this.tileSizeToUpdate = 0,
    Map<String, ObjectBuilder>? objectsBuilder,
  }) {
    _objectsBuilder = objectsBuilder ?? {};
    _basePath = path.replaceAll(path.split('/').last, '');
    _reader = TiledReader(path);
  }

  void registerObject(String name, ObjectBuilder builder) {
    _objectsBuilder[name] = builder;
  }

  Future<TiledWorldData> build() async {
    try {
      _tiledMap = await _reader.readMap();
      _tileWidthOrigin = _tiledMap?.tileWidth?.toDouble() ?? 0.0;
      _tileHeightOrigin = _tiledMap?.tileHeight?.toDouble() ?? 0.0;
      _tileWidth = forceTileSize?.x ?? _tileWidthOrigin;
      _tileHeight = forceTileSize?.y ?? _tileHeightOrigin;
      await _load(_tiledMap!);
    } catch (e) {
      onError?.call(e);
      // ignore: avoid_print
      print('(TiledWorldMap) Error: $e');
    }

    return Future.value(
      TiledWorldData(
        map: WorldMap(
          _tiles,
          tileSizeToUpdate: tileSizeToUpdate,
        ),
        components: _components,
      ),
    );
  }

  Future<void> _load(TiledMap tiledMap) async {
    for (var layer in tiledMap.layers ?? const <MapLayer>[]) {
      await _loadLayer(layer);
    }
  }

  Future<void> _loadLayer(MapLayer layer) async {
    if (layer.visible != true) return;

    if (layer is TileLayer) {
      await _addTileLayer(layer);
      countTileLayer++;
    }

    if (layer is ObjectLayer) {
      _addObjects(layer);
    }

    if (layer is ImageLayer) {
      _addImageLayer(layer);
      countImageLayer++;
    }

    if (layer is GroupLayer) {
      for (var layer in layer.layers ?? const <MapLayer>[]) {
        await _loadLayer(layer);
      }
    }
  }

  double _getDoubleByProportion(double? value) {
    return ((value ?? 0.0) * _tileWidth) / _tileWidthOrigin;
  }

  Future<void> _addTileLayer(TileLayer tileLayer) async {
    if (tileLayer.visible != true) return;
    int count = 0;
    double offsetX = _getDoubleByProportion(tileLayer.offsetX);
    double offsetY = _getDoubleByProportion(tileLayer.offsetY);
    double opacity = tileLayer.opacity ?? 1.0;
    bool layerIsAbove = tileLayer.properties
            ?.where((element) =>
                element.name == 'type' && element.value == ABOVE_TYPE)
            .isNotEmpty ??
        false;
    for (var tile in tileLayer.data ?? const <int>[]) {
      if (tile != 0) {
        var data = _getDataTile(tile);
        if (data != null) {
          bool tileIsAbove = ((data.type?.contains(ABOVE_TYPE) ?? false) ||
              (data.tileClass?.contains(ABOVE_TYPE) ?? false) ||
              layerIsAbove);
          bool isDynamic = data.type?.contains(DYNAMIC_ABOVE_TYPE) ?? false;
          if (tileIsAbove || isDynamic) {
            _addGameDecorationAbove(
              data,
              count,
              tileLayer,
              opacity,
              above: tileIsAbove,
            );
          } else {
            _addTile(data, count, tileLayer, offsetX, offsetY, opacity);
          }
        }
      }
      count++;
    }
  }

  void _addTile(
    TiledItemTileSet data,
    int count,
    TileLayer tileLayer,
    double offsetX,
    double offsetY,
    double opacity,
  ) {
    _tiles.add(
      TileModel(
        x: _getX(count, tileLayer.width?.toInt() ?? 1),
        y: _getY(count, tileLayer.width?.toInt() ?? 1),
        offsetX: offsetX,
        offsetY: offsetY,
        collisions: data.collisions,
        height: _tileHeight,
        width: _tileWidth,
        animation: data.animation,
        sprite: data.sprite,
        properties: data.properties,
        type: data.type,
        angle: data.angle,
        opacity: opacity,
        isFlipVertical: data.isFlipVertical,
        isFlipHorizontal: data.isFlipHorizontal,
      ),
    );
  }

  void _addGameDecorationAbove(
    TiledItemTileSet data,
    int count,
    TileLayer tileLayer,
    double opacity, {
    bool above = false,
  }) {
    if (data.animation != null) {
      _components.add(
        GameDecorationWithCollision.withAnimation(
          animation: data.animation!.getFutureSpriteAnimation(),
          position: Vector2(
            _getX(count, (tileLayer.width?.toInt()) ?? 1) * _tileWidth,
            _getY(count, (tileLayer.width?.toInt()) ?? 1) * _tileHeight,
          ),
          size: Vector2(_tileWidth, _tileHeight),
          collisions: data.collisions,
          aboveComponents: above,
        )
          ..angle = data.angle
          ..opacity = opacity
          ..isFlipHorizontally = data.isFlipHorizontal
          ..isFlipVertically = data.isFlipVertical
          ..properties = data.properties,
      );
    } else {
      if (data.sprite != null) {
        _components.add(
          GameDecorationWithCollision.withSprite(
            sprite: data.sprite!.getFutureSprite(),
            position: Vector2(
              _getX(count, (tileLayer.width?.toInt()) ?? 1) * _tileWidth,
              _getY(count, (tileLayer.width?.toInt()) ?? 1) * _tileHeight,
            ),
            size: Vector2(_tileWidth, _tileHeight),
            collisions: data.collisions,
            aboveComponents: above,
          )
            ..angle = data.angle
            ..isFlipHorizontally = data.isFlipHorizontal
            ..isFlipVertically = data.isFlipVertical
            ..properties = data.properties,
        );
      }
    }
  }

  double _getX(int index, int width) {
    return (index % (width == 0 ? 1 : width)).toDouble();
  }

  double _getY(int index, int width) {
    return (index / (width == 0 ? 1 : width)).floorToDouble();
  }

  TiledItemTileSet? _getDataTile(int gid) {
    int index = 0;
    double angle = 0;
    bool isFlipX = false;
    bool isFlipY = false;
    if (gid > GIT_FLIP_HORIZONTAL_90) {
      isFlipX = true;
      angle = 1.5708;
      index = gid - GIT_FLIP_HORIZONTAL_90;
    } else if (gid > GIT_ROTATE_180) {
      angle = 3.14159;
      index = gid - GIT_ROTATE_180;
    } else if (gid > GIT_ROTATE_90) {
      angle = 1.5708;
      index = gid - GIT_ROTATE_90;
    } else if (gid > GIT_FLIP_HORIZONTAL) {
      isFlipX = true;
      index = gid - GIT_FLIP_HORIZONTAL;
    } else if (gid > GIT_ROTATE_270) {
      angle = 4.71239;
      index = gid - GIT_ROTATE_270;
    } else if (gid > GIT_FLIP_VERTICAL) {
      isFlipY = true;
      index = gid - GIT_FLIP_VERTICAL;
    } else if (gid > GIT_FLIP_HORIZONTAL_270) {
      isFlipX = true;
      angle = 4.71239;
      index = gid - GIT_FLIP_HORIZONTAL_270;
    } else {
      index = gid;
    }

    TileSetDetail? tileSetContain;
    String pathTileset = '';
    String imagePath = '';
    int firsTgId = 0;
    int widthCount = 1;
    Vector2 spriteSize = Vector2.all(0);

    try {
      tileSetContain = _tiledMap?.tileSets?.lastWhere((tileSet) {
        return tileSet.firsTgId != null && index >= tileSet.firsTgId!;
      });

      firsTgId = tileSetContain?.firsTgId ?? 0;
      imagePath = tileSetContain?.image ?? '';
      widthCount =
          (tileSetContain?.imageWidth ?? 0) ~/ (tileSetContain?.tileWidth ?? 1);

      spriteSize = Vector2(
        tileSetContain?.tileWidth ?? 0.0,
        tileSetContain?.tileHeight ?? 0.0,
      );

      if (tileSetContain?.source != null) {
        pathTileset = tileSetContain!.source!.replaceAll(
          tileSetContain.source!.split('/').last,
          '',
        );
      }

      // to cases that the tileSet contain individual image.
      if (tileSetContain?.image == null &&
          tileSetContain?.tiles?.isNotEmpty == true) {
        int tilePosition = index - firsTgId;
        final tile = tileSetContain!.tiles![tilePosition];
        imagePath = tile.image ?? '';
        widthCount = 1;
        spriteSize = Vector2(
          tile.imageWidth ?? 0,
          tile.imageHeight ?? 0,
        );
        firsTgId = index;
      }
      // ignore: empty_catches
    } catch (e) {}

    if (tileSetContain != null) {
      final spritePosition = Vector2(
        _getX((index - firsTgId), widthCount),
        _getY((index - firsTgId), widthCount),
      );

      final pathSprite = '$_basePath$pathTileset$imagePath';

      TileModelSprite sprite;
      String tileKey = '$pathSprite/${spritePosition.x}/${spritePosition.y}';
      if (_tileModelSpriteCache.containsKey(tileKey)) {
        sprite = _tileModelSpriteCache[tileKey]!;
      } else {
        sprite = _tileModelSpriteCache[tileKey] = TileModelSprite(
          path: pathSprite,
          size: spriteSize,
          position: spritePosition,
        );
      }

      final animation = _getAnimation(
        tileSetContain,
        pathTileset,
        (index - firsTgId),
        widthCount,
      );

      final object = _getCollision(
        tileSetContain,
        (index - firsTgId),
      );

      return TiledItemTileSet(
        type: object.type,
        collisions: object.collisions,
        properties: object.properties,
        sprite: sprite,
        animation: animation,
        angle: angle,
        isFlipHorizontal: isFlipX,
        isFlipVertical: isFlipY,
      );
    } else {
      return null;
    }
  }

  void _addObjects(ObjectLayer layer) {
    if (layer.visible != true) return;
    double offsetX = _getDoubleByProportion(layer.offsetX);
    double offsetY = _getDoubleByProportion(layer.offsetY);
    for (var element in layer.objects ?? const <Objects>[]) {
      double x = _getDoubleByProportion(element.x) + offsetX;
      double y = _getDoubleByProportion(element.y) + offsetY;
      double width = _getDoubleByProportion(element.width);
      double height = _getDoubleByProportion(element.height);
      final collision = _getCollisionObject(x, y, width, height, element);

      if (element.text != null) {
        double fontSize = element.text!.pixelSize.toDouble();
        fontSize = (_tileWidth * fontSize) / _tileWidthOrigin;
        _components.add(
          TextGameComponent(
            name: element.name ?? '',
            text: element.text!.text,
            position: Vector2(x, y),
            style: material.TextStyle(
              fontSize: fontSize,
              fontFamily: element.text!.fontFamily,
              decoration:
                  element.text!.underline ? TextDecoration.underline : null,
              fontWeight: element.text!.bold
                  ? material.FontWeight.bold
                  : material.FontWeight.normal,
              fontStyle: element.text!.italic
                  ? material.FontStyle.italic
                  : material.FontStyle.normal,
              color: Color(
                int.parse('0xFF${element.text!.color.replaceAll('#', '')}'),
              ),
            ),
          ),
        );
      } else if (element.typeOrClass?.toLowerCase() == 'collision') {
        _components.add(
          CollisionGameComponent(
            name: element.name ?? '',
            position: Vector2(x, y) + (collision.align ?? Vector2.zero()),
            size: Vector2(collision.rect.width, collision.rect.height),
            collisions: [
              CollisionArea(collision.shape),
            ],
            properties: _extractOtherProperties(element.properties),
          ),
        );
      } else if (_objectsBuilder[element.name] != null) {
        final object = _objectsBuilder[element.name]?.call(
          TiledObjectProperties(
            Vector2(x, y),
            Vector2(width, height),
            element.typeOrClass,
            element.rotation,
            _extractOtherProperties(element.properties),
            element.name,
            element.id,
            collision,
          ),
        );

        if (object != null) {
          _components.add(object);
        }
      }
    }
  }

  TiledDataObjectCollision _getCollision(
    TileSetDetail tileSetContain,
    int index,
  ) {
    Iterable<TileSetItem> tileSetItemList = tileSetContain.tiles?.where(
          (element) => element.id == index,
        ) ??
        [];

    if (tileSetItemList.isNotEmpty) {
      List<TileSetObject> tileSetObjectList =
          tileSetItemList.first.objectGroup?.objects ?? [];

      Map<String, dynamic> properties = _extractOtherProperties(
        tileSetItemList.first.properties,
      );

      List<CollisionArea> collisions = [];

      if (tileSetObjectList.isNotEmpty) {
        for (var object in tileSetObjectList) {
          double width = _getDoubleByProportion(object.width);
          double height = _getDoubleByProportion(object.height);

          double x = _getDoubleByProportion(object.x);
          double y = _getDoubleByProportion(object.y);

          CollisionArea ca = CollisionArea.rectangle(
            size: Vector2(width, height),
            align: Vector2(x, y),
          );

          if (object.ellipse == true) {
            ca = CollisionArea.circle(
              radius: (width > height ? width : height) / 2,
              align: Vector2(x, y),
            );
          }

          if (object.polygon?.isNotEmpty == true) {
            ca = _normalizePolygon(x, y, object.polygon!);
          }

          collisions.add(ca);
        }
      }
      return TiledDataObjectCollision(
        collisions: collisions,
        type: tileSetItemList.first.typeOrClass ?? '',
        properties: properties,
      );
    }
    return TiledDataObjectCollision();
  }

  TileModelAnimation? _getAnimation(
    TileSetDetail tileSetContain,
    String pathTileset,
    int index,
    int widthCount,
  ) {
    try {
      TileSetItem tileSetItemList = tileSetContain.tiles!.firstWhere(
        (element) => element.id == index,
      );

      List<FrameAnimation> animationFrames = tileSetItemList.animation ?? [];

      List<TileModelSprite> frames = [];
      if ((animationFrames.isNotEmpty)) {
        double stepTime = (animationFrames[0].duration ?? 100) / 1000;

        for (var frame in animationFrames) {
          double y = _getY((frame.tileid ?? 0), widthCount);
          double x = _getX((frame.tileid ?? 0), widthCount);

          final spritePath = '$_basePath$pathTileset${tileSetContain.image}';

          TileModelSprite sprite = TileModelSprite(
            path: spritePath,
            size: Vector2(
              tileSetContain.tileWidth ?? 0,
              tileSetContain.tileHeight ?? 0,
            ),
            position: Vector2(x, y),
          );
          frames.add(sprite);
        }

        return TileModelAnimation(
          stepTime: stepTime,
          frames: frames,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _extractOtherProperties(List<Property>? properties) {
    final map = <String, dynamic>{};

    for (var element in properties ?? const <Property>[]) {
      if (element.value != null && element.name != null) {
        map[element.name!] = element.value;
      }
    }
    return map;
  }

  void _addImageLayer(ImageLayer layer) {
    if (!(layer.visible ?? false)) return;
    _components.add(
      BackgroundImageGame(
        id: layer.id,
        imagePath: '$_basePath${layer.image}',
        offset: Vector2(
          (layer.x ?? 0.0) + (layer.offsetX ?? 0.0),
          (layer.y ?? 0.0) + (layer.offsetY ?? 0.0),
        ),
        parallaxX: layer.parallaxY,
        parallaxY: layer.parallaxX,
        factor: _tileWidth / _tileWidthOrigin,
        opacity: layer.opacity ?? 1,
        isBackground: countTileLayer == 0,
        priorityImage: countImageLayer,
      ),
    );
  }

  CollisionArea _getCollisionObject(
    double x,
    double y,
    double width,
    double height,
    Objects object,
  ) {
    CollisionArea ca = CollisionArea.rectangle(
      size: Vector2(width, height),
    );

    if (object.ellipse == true) {
      ca = CollisionArea.circle(
        radius: (width > height ? width : height) / 2,
      );
    }

    if (object.polygon?.isNotEmpty == true) {
      ca = _normalizePolygon(x, y, object.polygon!, isObject: true);
    }
    return ca;
  }

  CollisionArea _normalizePolygon(
    double x,
    double y,
    List<Polygon> polygon, {
    bool isObject = false,
  }) {
    double minorX = _getDoubleByProportion(polygon.first.x);
    double minorY = _getDoubleByProportion(polygon.first.y);
    List<Vector2> points = polygon.map((e) {
      Vector2 vector = Vector2(
        _getDoubleByProportion(e.x),
        _getDoubleByProportion(e.y),
      );

      if (vector.x < minorX) {
        minorX = vector.x;
      }

      if (vector.y < minorY) {
        minorY = vector.y;
      }
      return vector;
    }).toList();

    if (minorX < 0) {
      points = points.map((e) {
        return Vector2(e.x - minorX, e.y);
      }).toList();
    }

    if (minorY < 0) {
      points = points.map((e) {
        return Vector2(e.x, e.y - minorY);
      }).toList();
    }

    double alignX = x - points.first.x;
    double alignY = y - points.first.y;

    if (isObject) {
      alignX = minorX;
      alignY = minorY;
    }

    return CollisionArea.polygon(
      points: points,
      align: Vector2(alignX, alignY),
    );
  }
}
