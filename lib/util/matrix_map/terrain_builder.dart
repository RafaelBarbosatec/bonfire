import 'dart:math';

import 'package:bonfire/map/tile/tile_model.dart';
import 'package:bonfire/util/matrix_map/map_terrain.dart';
import 'package:bonfire/util/matrix_map/matrix_map_generator.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 01/06/22
class TerrainBuilder {
  final double tileSize;
  final List<MapTerrain> terrainList;

  TerrainBuilder({required this.tileSize, required this.terrainList});

  TileModel build(ItemMatrixProperties prop) {
    Iterable<MapTerrain> findList =
        terrainList.where((element) => element.value == prop.value);

    if (findList.isEmpty) {
      return _buildDefault(prop);
    }

    try {
      if (prop.valueLeft == prop.value &&
          prop.valueRight == prop.value &&
          prop.valueTop == prop.value &&
          prop.valueBottom == prop.value) {
        MapTerrain terrain = findList.where((element) {
          return !(element is MapTerrainCorners);
        }).first;
        return _buildTile(terrain, prop);
      } else {
        return _buildTileCorner(findList, prop);
      }
    } catch (E) {
      return _buildDefault(prop);
    }
  }

  TileModel _buildTileCorner(
    Iterable<MapTerrain> terrains,
    ItemMatrixProperties prop,
  ) {
    TileModelSprite? sprite;
    Iterable<MapTerrainCorners> corners =
        terrains.whereType<MapTerrainCorners>();
    MapTerrainCorners? left =
        firstWhere(corners, (element) => element.to == prop.valueLeft);
    if (left != null) {
      sprite = left.spriteSheet.left;
    }
    if (sprite == null) {
      MapTerrainCorners? right =
          firstWhere(corners, (element) => element.to == prop.valueRight);
      if (right != null) {
        sprite = right.spriteSheet.right;
      }
    }

    if (sprite == null) {
      MapTerrainCorners? top =
          firstWhere(corners, (element) => element.to == prop.valueTop);
      if (top != null) {
        sprite = top.spriteSheet.top;
      }
    }

    if (sprite == null) {
      MapTerrainCorners? bottom =
          firstWhere(corners, (element) => element.to == prop.valueBottom);
      if (bottom != null) {
        sprite = bottom.spriteSheet.bottom;
      }
    }

    if (sprite == null) {
      MapTerrain? terrain = firstWhere(terrains, (element) {
        return !(element is MapTerrainCorners);
      });
      if (terrain != null) {
        sprite = _getSingleSprite(terrain);
      }
    }

    return TileModel(
      x: prop.position.x,
      y: prop.position.y,
      width: tileSize,
      height: tileSize,
      sprite: sprite,
    );
  }

  TileModel _buildTile(MapTerrain terrain, ItemMatrixProperties prop) {
    TileModelSprite? sprite = _getSingleSprite(terrain);

    return TileModel(
      x: prop.position.x,
      y: prop.position.y,
      width: tileSize,
      height: tileSize,
      sprite: sprite,
    );
  }

  TileModel _buildDefault(ItemMatrixProperties prop) {
    return TileModel(
      x: prop.position.x,
      y: prop.position.y,
      width: tileSize,
      height: tileSize,
    );
  }

  E? firstWhere<E>(
    Iterable<E> list,
    bool test(E element),
  ) {
    for (E element in list) {
      if (test(element)) return element;
    }
    return null;
  }

  TileModelSprite? _getSingleSprite(MapTerrain terrain) {
    if (terrain.sprites.length > 1 &&
        terrain.sprites.length == terrain.spriteRandom.length) {
      double ran = Random().nextDouble();
      return terrain.sprites[terrain.spriteRandom.indexWhere((element) {
        return element <= ran;
      })];
    } else {
      return terrain.sprites.first;
    }
  }
}
