import 'package:bonfire/map/base/tile_model.dart';
import 'package:bonfire/map/matrix_map/matrix_map_generator.dart';
import 'package:bonfire/util/functions.dart';
import 'package:bonfire/util/pair.dart';

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

/// Class responsible to create tiles map with SpriteSheet.
class TerrainBuilder {
  final double tileSize;
  final List<MapTerrain> terrainList;

  TerrainBuilder({required this.tileSize, required this.terrainList});

  TileModel build(ItemMatrixProperties prop) {
    Iterable<MapTerrain> findList = terrainList.where(
      (element) => element.value == prop.value,
    );

    if (findList.isEmpty) {
      return _buildDefault(prop);
    }

    try {
      if (prop.isCenterTile) {
        MapTerrain terrain = findList.where((element) {
          return element is! MapTerrainCorners;
        }).first;
        return _buildTile(terrain, prop);
      } else {
        return _buildTileCorner(findList, prop);
      }
    } catch (e) {
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

    MapTerrain? terrain;

    final corner = _handleTopCorners(corners, prop);
    sprite = corner.first;
    terrain = corner.second;

    if (sprite == null) {
      final corner = _handleBottomCorners(corners, prop);
      sprite = corner.first;
      terrain = corner.second;
    }

    if (sprite == null) {
      MapTerrainCorners? left = firstWhere(
        corners,
        (element) => element.to == prop.valueLeft,
      );

      if (left != null) {
        terrain = left;
        sprite = left.spriteSheet.left;
      }
    }

    if (sprite == null) {
      MapTerrainCorners? right = firstWhere(
        corners,
        (element) => element.to == prop.valueRight,
      );

      if (right != null) {
        terrain = right;
        sprite = right.spriteSheet.right;
      }
    }

    if (sprite == null) {
      MapTerrainCorners? top = firstWhere(
        corners,
        (element) => element.to == prop.valueTop,
      );
      if (top != null) {
        terrain = top;
        sprite = top.spriteSheet.top;
      }
    }

    if (sprite == null) {
      MapTerrainCorners? bottom = firstWhere(
        corners,
        (element) => element.to == prop.valueBottom,
      );
      if (bottom != null) {
        terrain = bottom;
        sprite = bottom.spriteSheet.bottom;
      }
    }

    if (sprite == null) {
      MapTerrain? center = firstWhere(
        terrains,
        (element) => element is! MapTerrainCorners,
      );
      if (center != null) {
        terrain = center;
        sprite = terrain.getSingleSprite();
      }
    }

    return TileModel(
      x: prop.position.x,
      y: prop.position.y,
      width: tileSize,
      height: tileSize,
      sprite: sprite,
      properties: terrain?.properties,
      collisions: terrain?.getCollisionClone(),
      type: terrain?.type,
    );
  }

  TileModel _buildTile(MapTerrain terrain, ItemMatrixProperties prop) {
    return TileModel(
      x: prop.position.x,
      y: prop.position.y,
      width: tileSize,
      height: tileSize,
      sprite: terrain.getSingleSprite(),
      properties: terrain.properties,
      collisions: terrain.getCollisionClone(checkOnlyClose: true),
      type: terrain.type,
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

  Pair<TileModelSprite?, MapTerrain?> _handleBottomCorners(
    Iterable<MapTerrainCorners> corners,
    ItemMatrixProperties prop,
  ) {
    TileModelSprite? sprite;
    MapTerrain? terrain;
    if (prop.valueBottom != prop.value &&
        prop.valueBottom == prop.valueBottomLeft &&
        prop.valueBottom == prop.valueLeft) {
      MapTerrainCorners? bottomLeft = firstWhere(
        corners,
        (element) => element.to == prop.valueBottom,
      );
      if (bottomLeft != null) {
        terrain = bottomLeft;
        sprite = bottomLeft.spriteSheet.bottomLeft;
      }
    }

    if (prop.valueBottom != prop.value &&
        prop.valueBottom == prop.valueBottomRight &&
        prop.valueBottom == prop.valueRight) {
      MapTerrainCorners? bottomRight = firstWhere(
        corners,
        (element) => element.to == prop.valueBottom,
      );
      if (bottomRight != null) {
        terrain = bottomRight;
        sprite = bottomRight.spriteSheet.bottomRight;
      }
    }

    if (prop.valueBottomLeft != prop.value &&
        prop.valueLeft == prop.value &&
        prop.valueLeft == prop.valueBottom) {
      MapTerrainCorners? bottomLeft = firstWhere(
        corners,
        (element) => element.to == prop.valueBottomLeft,
      );
      if (bottomLeft != null) {
        terrain = bottomLeft;
        sprite = bottomLeft.spriteSheet.invertedTopRight;
      }
    }

    if (prop.valueBottomRight != prop.value &&
        prop.valueRight == prop.value &&
        prop.valueRight == prop.valueBottom) {
      MapTerrainCorners? bottomRight = firstWhere(
        corners,
        (element) => element.to == prop.valueBottomRight,
      );
      if (bottomRight != null) {
        terrain = bottomRight;
        sprite = bottomRight.spriteSheet.invertedTopLeft;
      }
    }

    return Pair<TileModelSprite?, MapTerrain?>(sprite, terrain);
  }

  Pair<TileModelSprite?, MapTerrain?> _handleTopCorners(
    Iterable<MapTerrainCorners> corners,
    ItemMatrixProperties prop,
  ) {
    TileModelSprite? sprite;
    MapTerrain? terrain;
    if (prop.valueTop != prop.value &&
        prop.valueTop == prop.valueTopLeft &&
        prop.valueTop == prop.valueLeft) {
      MapTerrainCorners? topLeft = firstWhere(
        corners,
        (element) => element.to == prop.valueTop,
      );
      if (topLeft != null) {
        terrain = topLeft;
        sprite = topLeft.spriteSheet.topLeft;
      }
    }

    if (prop.valueTop != prop.value &&
        prop.valueTop == prop.valueTopRight &&
        prop.valueTop == prop.valueRight) {
      MapTerrainCorners? topRight = firstWhere(
        corners,
        (element) => element.to == prop.valueTop,
      );
      if (topRight != null) {
        terrain = topRight;
        sprite = topRight.spriteSheet.topRight;
      }
    }

    if (prop.valueTopLeft != prop.value &&
        prop.valueLeft == prop.value &&
        prop.valueLeft == prop.valueTop) {
      MapTerrainCorners? topLeftInverted = firstWhere(
        corners,
        (element) => element.to == prop.valueTopLeft,
      );
      if (topLeftInverted != null) {
        terrain = topLeftInverted;
        sprite = topLeftInverted.spriteSheet.invertedBottomRight;
      }
    }

    if (prop.valueTopRight != prop.value &&
        prop.valueRight == prop.value &&
        prop.valueRight == prop.valueTop) {
      MapTerrainCorners? topRightInverted = firstWhere(
        corners,
        (element) => element.to == prop.valueTopRight,
      );
      if (topRightInverted != null) {
        terrain = topRightInverted;
        sprite = topRightInverted.spriteSheet.invertedBottomLeft;
      }
    }

    return Pair<TileModelSprite?, MapTerrain?>(sprite, terrain);
  }
}
