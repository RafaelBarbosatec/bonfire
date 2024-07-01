// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'dart:ui';

import 'package:bonfire/background/background_image_game.dart';
import 'package:bonfire/bonfire.dart' hide TileComponent;
import 'package:bonfire/map/base/layer.dart';
import 'package:bonfire/map/tiled/model/tiled_world_data.dart';
import 'package:bonfire/map/util/map_layer_mapper.dart';
import 'package:bonfire/util/collision_game_component.dart';
import 'package:bonfire/util/text_game_component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:tiledjsonreader/map/layer/group_layer.dart';
import 'package:tiledjsonreader/map/layer/image_layer.dart';
import 'package:tiledjsonreader/map/layer/map_layer.dart';
import 'package:tiledjsonreader/map/layer/object_layer.dart';
import 'package:tiledjsonreader/map/layer/objects.dart';
import 'package:tiledjsonreader/map/layer/tile_layer.dart' as tiled;
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
  static const _mapOrientationSupported = 'orthogonal';

  final Vector2? forceTileSize;
  final ValueChanged<Object>? onError;
  final WorldMapReader<TiledMap> reader;
  final double sizeToUpdate;
  final List<Layer> _layers = [];
  final List<GameComponent> _components = [];
  String? _basePath;
  TiledMap? _tiledMap;
  double _tileWidth = 0;
  double _tileHeight = 0;
  double _tileWidthOrigin = 0;
  double _tileHeightOrigin = 0;
  Map<String, ObjectBuilder> _objectsBuilder = {};
  final Map<String, TileSprite> _tileModelSpriteCache = {};
  int countTileLayer = 0;
  int countImageLayer = 0;

  TiledWorldBuilder(
    this.reader, {
    this.forceTileSize,
    this.onError,
    this.sizeToUpdate = 0,
    Map<String, ObjectBuilder>? objectsBuilder,
  }) {
    _objectsBuilder = objectsBuilder ?? {};
    _basePath = reader.basePath;
  }

  void registerObject(String name, ObjectBuilder builder) {
    _objectsBuilder[name] = builder;
  }

  Future<WorldBuildData> build() async {
    try {
      _tiledMap = await reader.readMap();
      if (_tiledMap?.orientation != _mapOrientationSupported) {
        throw Exception(
          'Bonfire have only suport to $_mapOrientationSupported orientation.',
        );
      }
      _tileWidthOrigin = _tiledMap?.tileWidth?.toDouble() ?? 0.0;
      _tileHeightOrigin = _tiledMap?.tileHeight?.toDouble() ?? 0.0;
      _tileWidth = forceTileSize?.x ?? _tileWidthOrigin;
      _tileHeight = forceTileSize?.y ?? _tileHeightOrigin;
      await _load(_tiledMap!);
    } catch (e) {
      onError?.call(e);
      // ignore: avoid_print
      print('(TiledWorldBuilder) Error: $e');
    }

    return Future.value(
      WorldBuildData(
        map: WorldMap(
          _layers.where((e) => e.tiles.isNotEmpty).toList(),
          tileSizeToUpdate: sizeToUpdate,
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

    if (layer is tiled.TileLayer) {
      _layers.add(MapLayerMapper.toLayer(layer, countTileLayer));
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

  Future<void> _addTileLayer(tiled.TileLayer tileLayer) async {
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
    tiled.TileLayer tileLayer,
    double offsetX,
    double offsetY,
    double opacity,
  ) {
    _layers.last.tiles.add(
      Tile(
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
        tileClass: data.type ?? data.tileClass,
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
    tiled.TileLayer tileLayer,
    double opacity, {
    bool above = false,
  }) {
    GameDecoration? comp;
    if (data.animation != null) {
      comp = GameDecorationWithCollision.withAnimation(
        animation: data.animation!.getFutureSpriteAnimation(),
        position: Vector2(
          _getX(count, (tileLayer.width?.toInt()) ?? 1) * _tileWidth,
          _getY(count, (tileLayer.width?.toInt()) ?? 1) * _tileHeight,
        ),
        size: Vector2(_tileWidth, _tileHeight),
        collisions: data.collisions,
        renderAboveComponents: above,
      )
        ..angle = data.angle
        ..opacity = opacity
        ..properties = data.properties;
      _components.add(comp);
    } else {
      if (data.sprite != null) {
        comp = GameDecorationWithCollision.withSprite(
          sprite: data.sprite!.getFutureSprite(),
          position: Vector2(
            _getX(count, (tileLayer.width?.toInt()) ?? 1) * _tileWidth,
            _getY(count, (tileLayer.width?.toInt()) ?? 1) * _tileHeight,
          ),
          size: Vector2(_tileWidth, _tileHeight),
          collisions: data.collisions,
          renderAboveComponents: above,
        )
          ..angle = data.angle
          ..properties = data.properties;
      }
    }

    if (data.isFlipHorizontal) {
      comp?.flipHorizontallyAroundCenter();
    }

    if (data.isFlipVertical) {
      comp?.flipVerticallyAroundCenter();
    }
    if (comp != null) {
      _components.add(comp);
    }
  }

  double _getX(int index, int width) {
    return (index % (width == 0 ? 1 : width)).toDouble();
  }

  double _getY(int index, int width) {
    return (index / (width == 0 ? 1 : width)).floorToDouble();
  }

  TiledItemTileSet? _getDataTile(int gid) {
    final gidInfo = tiled.TileLayer.getGidInfo(gid);
    int index = gidInfo.index;

    TileSetDetail? tileSetContain;
    String pathTileset = '';
    String imagePath = '';
    int firsTgId = 0;
    int tilesetFirsTgId = 0;
    int widthCount = 1;
    Vector2 spriteSize = Vector2.all(0);

    try {
      tileSetContain = _tiledMap?.tileSets?.lastWhere((tileSet) {
        return tileSet.firsTgId != null && index >= tileSet.firsTgId!;
      });

      firsTgId = tileSetContain?.firsTgId ?? 0;
      tilesetFirsTgId = firsTgId;
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

      TileSprite sprite;
      String tileKey = '$pathSprite/${spritePosition.x}/${spritePosition.y}';
      if (_tileModelSpriteCache.containsKey(tileKey)) {
        sprite = _tileModelSpriteCache[tileKey]!;
      } else {
        sprite = _tileModelSpriteCache[tileKey] = TileSprite(
          path: pathSprite,
          size: spriteSize,
          position: spritePosition,
        );
      }

      final animation = _getAnimation(
        tileSetContain,
        pathTileset,
        (index - tilesetFirsTgId),
        widthCount,
      );

      final object = _getCollision(
        tileSetContain,
        (index - tilesetFirsTgId),
      );

      return TiledItemTileSet(
        type: object.type,
        collisions: object.collisions,
        properties: object.properties,
        sprite: sprite,
        animation: animation,
        angle: gidInfo.angle,
        isFlipHorizontal: gidInfo.isFlipX,
        isFlipVertical: gidInfo.isFlipY,
      );
    } else {
      return null;
    }
  }

  void _addObjects(ObjectLayer layer) {
    if (layer.visible != true) return;
    bool isCollisionLayer = layer.layerClass?.toLowerCase() == 'collision';
    double offsetX = _getDoubleByProportion(layer.offsetX);
    double offsetY = _getDoubleByProportion(layer.offsetY);
    for (var element in layer.objects ?? const <Objects>[]) {
      double x = _getDoubleByProportion(element.x) + offsetX;
      double y = _getDoubleByProportion(element.y) + offsetY;
      double width = _getDoubleByProportion(element.width);
      double height = _getDoubleByProportion(element.height);
      double rotation = (element.rotation ?? 0) * pi / 180;
      bool isObjectCollision =
          element.typeOrClass?.toLowerCase() == 'collision' || isCollisionLayer;
      final collision = _getCollisionObject(
        x,
        y,
        width,
        height,
        ellipse: element.ellipse ?? false,
        polygon: element.polygon,
        isObjectCollision: isObjectCollision,
      );

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
          )..angle = rotation,
        );
      } else if (isObjectCollision) {
        _components.add(
          CollisionMapComponent(
            name: element.name ?? '',
            position: Vector2(x, y),
            size: Vector2(collision.size.x, collision.size.y),
            collisions: [collision],
            properties:
                MapLayerMapper.extractOtherProperties(element.properties),
          )..angle = rotation,
        );
      } else if (_objectsBuilder[element.name] != null) {
        final object = _objectsBuilder[element.name]?.call(
          TiledObjectProperties(
            Vector2(x, y),
            Vector2(width, height),
            element.typeOrClass,
            rotation,
            MapLayerMapper.extractOtherProperties(element.properties),
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

      Map<String, dynamic> properties = MapLayerMapper.extractOtherProperties(
        tileSetItemList.first.properties,
      );

      List<ShapeHitbox> collisions = [];

      if (tileSetObjectList.isNotEmpty) {
        for (var object in tileSetObjectList) {
          double width = _getDoubleByProportion(object.width);
          double height = _getDoubleByProportion(object.height);

          double x = _getDoubleByProportion(object.x);
          double y = _getDoubleByProportion(object.y);

          collisions.add(
            _getCollisionObject(
              x,
              y,
              width,
              height,
              ellipse: object.ellipse ?? false,
              polygon: object.polygon,
            ),
          );
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

  TilelAnimation? _getAnimation(
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

      List<TileSprite> frames = [];
      if ((animationFrames.isNotEmpty)) {
        double stepTime = (animationFrames[0].duration ?? 100) / 1000;

        for (var frame in animationFrames) {
          double y = _getY((frame.tileid ?? 0), widthCount);
          double x = _getX((frame.tileid ?? 0), widthCount);

          final spritePath = '$_basePath$pathTileset${tileSetContain.image}';

          TileSprite sprite = TileSprite(
            path: spritePath,
            size: Vector2(
              tileSetContain.tileWidth ?? 0,
              tileSetContain.tileHeight ?? 0,
            ),
            position: Vector2(x, y),
          );
          frames.add(sprite);
        }

        return TilelAnimation(
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

  ShapeHitbox _getCollisionObject(
    double x,
    double y,
    double width,
    double height, {
    bool ellipse = false,
    List<Polygon>? polygon,
    bool isObjectCollision = false,
  }) {
    ShapeHitbox ca = RectangleHitbox(
      size: Vector2(width, height),
      position: isObjectCollision ? null : Vector2(x, y),
      isSolid: true,
      // Angle here is not used because
      // collision object is already rotated
    );

    if (ellipse == true) {
      ca = CircleHitbox(
        radius: (width > height ? width : height) / 2,
        position: isObjectCollision ? null : Vector2(x, y),
        isSolid: true,
      );
    }

    if (polygon?.isNotEmpty == true) {
      ca = _normalizePolygon(x, y, polygon!, isObjectCollision);
    }
    return ca;
  }

  ShapeHitbox _normalizePolygon(
    double x,
    double y,
    List<Polygon> polygon,
    bool isObjectCollision,
  ) {
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

    if (isObjectCollision) {
      alignX = minorX;
      alignY = minorY;
    }

    return PolygonHitbox(
      points,
      position: Vector2(alignX, alignY),
      isSolid: true,
    );
  }
}
