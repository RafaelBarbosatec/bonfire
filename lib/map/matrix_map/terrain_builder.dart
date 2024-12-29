import 'package:bonfire/map/base/tile.dart';
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

  Tile build(ItemMatrixProperties prop) {
    final findList = terrainList.where(
      (element) => element.value == prop.value,
    );

    if (findList.isEmpty) {
      return _buildDefault(prop);
    }

    try {
      if (prop.isCenterTile) {
        final terrain = findList.where((element) {
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

  Tile _buildTileCorner(
    Iterable<MapTerrain> terrains,
    ItemMatrixProperties prop,
  ) {
    TileSprite? sprite;
    final corners = terrains.whereType<MapTerrainCorners>();

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
      final MapTerrainCorners? left = firstWhere(
        corners,
        (element) => element.to == prop.valueLeft,
      );

      if (left != null) {
        terrain = left;
        sprite = left.spriteSheet.left;
      }
    }

    if (sprite == null) {
      final MapTerrainCorners? right = firstWhere(
        corners,
        (element) => element.to == prop.valueRight,
      );

      if (right != null) {
        terrain = right;
        sprite = right.spriteSheet.right;
      }
    }

    if (sprite == null) {
      final MapTerrainCorners? top = firstWhere(
        corners,
        (element) => element.to == prop.valueTop,
      );
      if (top != null) {
        terrain = top;
        sprite = top.spriteSheet.top;
      }
    }

    if (sprite == null) {
      final MapTerrainCorners? bottom = firstWhere(
        corners,
        (element) => element.to == prop.valueBottom,
      );
      if (bottom != null) {
        terrain = bottom;
        sprite = bottom.spriteSheet.bottom;
      }
    }

    if (sprite == null) {
      final MapTerrain? center = firstWhere(
        terrains,
        (element) => element is! MapTerrainCorners,
      );
      if (center != null) {
        terrain = center;
        sprite = terrain.getSingleSprite();
      }
    }

    return Tile(
      x: prop.position.x,
      y: prop.position.y,
      width: tileSize,
      height: tileSize,
      sprite: sprite,
      properties: terrain?.properties,
      collisions: terrain?.getCollisionClone(),
      tileClass: terrain?.type,
    );
  }

  Tile _buildTile(MapTerrain terrain, ItemMatrixProperties prop) {
    return Tile(
      x: prop.position.x,
      y: prop.position.y,
      width: tileSize,
      height: tileSize,
      sprite: terrain.getSingleSprite(),
      properties: terrain.properties,
      collisions: terrain.getCollisionClone(checkOnlyClose: true),
      tileClass: terrain.type,
    );
  }

  Tile _buildDefault(ItemMatrixProperties prop) {
    return Tile(
      x: prop.position.x,
      y: prop.position.y,
      width: tileSize,
      height: tileSize,
    );
  }

  Pair<TileSprite?, MapTerrain?> _handleBottomCorners(
    Iterable<MapTerrainCorners> corners,
    ItemMatrixProperties prop,
  ) {
    TileSprite? sprite;
    MapTerrain? terrain;
    if (prop.valueBottom != prop.value &&
        prop.valueBottom == prop.valueBottomLeft &&
        prop.valueBottom == prop.valueLeft) {
      final MapTerrainCorners? bottomLeft = firstWhere(
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
      final MapTerrainCorners? bottomRight = firstWhere(
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
      final MapTerrainCorners? bottomLeft = firstWhere(
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
      final MapTerrainCorners? bottomRight = firstWhere(
        corners,
        (element) => element.to == prop.valueBottomRight,
      );
      if (bottomRight != null) {
        terrain = bottomRight;
        sprite = bottomRight.spriteSheet.invertedTopLeft;
      }
    }

    return Pair<TileSprite?, MapTerrain?>(sprite, terrain);
  }

  Pair<TileSprite?, MapTerrain?> _handleTopCorners(
    Iterable<MapTerrainCorners> corners,
    ItemMatrixProperties prop,
  ) {
    TileSprite? sprite;
    MapTerrain? terrain;
    if (prop.valueTop != prop.value &&
        prop.valueTop == prop.valueTopLeft &&
        prop.valueTop == prop.valueLeft) {
      final MapTerrainCorners? topLeft = firstWhere(
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
      final MapTerrainCorners? topRight = firstWhere(
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
      final MapTerrainCorners? topLeftInverted = firstWhere(
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
      final MapTerrainCorners? topRightInverted = firstWhere(
        corners,
        (element) => element.to == prop.valueTopRight,
      );
      if (topRightInverted != null) {
        terrain = topRightInverted;
        sprite = topRightInverted.spriteSheet.invertedBottomLeft;
      }
    }

    return Pair<TileSprite?, MapTerrain?>(sprite, terrain);
  }
}
