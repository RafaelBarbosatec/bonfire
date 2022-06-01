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
          prop.valueBottom == prop.value &&
          prop.valueBottomLeft == prop.value &&
          prop.valueBottomRight == prop.value &&
          prop.valueTopLeft == prop.value &&
          prop.valueTopRight == prop.value) {
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

    // if (prop.valueTop == prop.valueTopLeft && prop.valueTop == prop.valueLeft) {
    //   MapTerrainCorners? topLeft =
    //       firstWhere(corners, (element) => element.to == prop.valueTop);
    //   if (topLeft != null) {
    //     sprite = topLeft.spriteSheet.topLeft;
    //   }
    // }
    //
    // if (prop.valueTop == prop.valueTopRight &&
    //     prop.valueTop == prop.valueRight) {
    //   MapTerrainCorners? topRight =
    //       firstWhere(corners, (element) => element.to == prop.valueTop);
    //   if (topRight != null) {
    //     sprite = topRight.spriteSheet.topRight;
    //   }
    // }

    sprite = _handleTopCorners(corners, prop);

    if (sprite == null) {
      sprite = _handleBottomCorners(corners, prop);
    }

    if (sprite == null) {
      MapTerrainCorners? left =
          firstWhere(corners, (element) => element.to == prop.valueLeft);
      if (left != null) {
        sprite = left.spriteSheet.left;
      }
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

  TileModelSprite? _handleBottomCorners(
    Iterable<MapTerrainCorners> corners,
    ItemMatrixProperties prop,
  ) {
    TileModelSprite? sprite;
    if (prop.valueBottom != prop.value &&
        prop.valueBottom == prop.valueBottomLeft &&
        prop.valueBottom == prop.valueLeft) {
      MapTerrainCorners? bottomLeft =
          firstWhere(corners, (element) => element.to == prop.valueBottom);
      if (bottomLeft != null) {
        sprite = bottomLeft.spriteSheet.bottomLeft;
      }
    }

    if (prop.valueBottom != prop.value &&
        prop.valueBottom == prop.valueBottomRight &&
        prop.valueBottom == prop.valueRight) {
      MapTerrainCorners? bottomRight =
          firstWhere(corners, (element) => element.to == prop.valueBottom);
      if (bottomRight != null) {
        sprite = bottomRight.spriteSheet.bottomRight;
      }
    }

    if (prop.valueBottomLeft != prop.value &&
        prop.valueLeft == prop.value &&
        prop.valueLeft == prop.valueBottom) {
      MapTerrainCorners? bottomLeft =
          firstWhere(corners, (element) => element.to == prop.valueBottomLeft);
      if (bottomLeft != null) {
        sprite = bottomLeft.spriteSheet.invertedTopRight;
      }
    }

    if (prop.valueBottomRight != prop.value &&
        prop.valueRight == prop.value &&
        prop.valueRight == prop.valueBottom) {
      MapTerrainCorners? bottomRight =
          firstWhere(corners, (element) => element.to == prop.valueBottomRight);
      if (bottomRight != null) {
        sprite = bottomRight.spriteSheet.invertedTopLeft;
      }
    }

    return sprite;
  }

  TileModelSprite? _handleTopCorners(
      Iterable<MapTerrainCorners> corners, ItemMatrixProperties prop) {
    TileModelSprite? sprite;
    if (prop.valueTop != prop.value &&
        prop.valueTop == prop.valueTopLeft &&
        prop.valueTop == prop.valueLeft) {
      MapTerrainCorners? topLeft =
          firstWhere(corners, (element) => element.to == prop.valueTop);
      if (topLeft != null) {
        sprite = topLeft.spriteSheet.topLeft;
      }
    }

    if (prop.valueTop != prop.value &&
        prop.valueTop == prop.valueTopRight &&
        prop.valueTop == prop.valueRight) {
      MapTerrainCorners? topRight =
          firstWhere(corners, (element) => element.to == prop.valueTop);
      if (topRight != null) {
        sprite = topRight.spriteSheet.topRight;
      }
    }

    if (prop.valueTopLeft != prop.value &&
        prop.valueLeft == prop.value &&
        prop.valueLeft == prop.valueTop) {
      MapTerrainCorners? topLeftInverted =
          firstWhere(corners, (element) => element.to == prop.valueTopLeft);
      if (topLeftInverted != null) {
        sprite = topLeftInverted.spriteSheet.invertedBottomRight;
      }
    }

    if (prop.valueTopRight != prop.value &&
        prop.valueRight == prop.value &&
        prop.valueRight == prop.valueTop) {
      MapTerrainCorners? topRightInverted =
          firstWhere(corners, (element) => element.to == prop.valueTopRight);
      if (topRightInverted != null) {
        sprite = topRightInverted.spriteSheet.invertedBottomLeft;
      }
    }

    return sprite;
  }
}
