import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/random_map/noise_generator.dart';
import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/foundation.dart';

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
/// on 02/06/22
class MapGenerator {
  static const double TILE_WATER = 0;
  static const double TILE_EARTH = 1;
  static const double TILE_GRASS = 2;
  late TerrainBuilder _terrainBuilder;
  final double tileSize;
  final Vector2 size;

  MapGenerator(this.size, this.tileSize) {
    _terrainBuilder = TerrainBuilder(
      tileSize: tileSize,
      terrainList: _buildTerrainList(),
    );
  }

  Future<MapGame> buildMap() async {
    final matrix = await compute(
      generateNoise,
      {
        'h': size.y.toInt(),
        'w': size.x.toInt(),
        'seed': Random().nextInt(2000),
        'frequency': 0.02,
        'noiseType': NoiseType.PerlinFractal,
        'cellularDistanceFunction': CellularDistanceFunction.Natural,
      },
    );

    return MatrixMapGenerator.generate(
      matrix: matrix,
      builder: _terrainBuilder.build,
    );
  }

  List<MapTerrain> _buildTerrainList() {
    return [
      MapTerrain(
        value: TILE_WATER,
        collisionOnlyCloseCorners: true,
        collisions: [CollisionArea.rectangle(size: Vector2.all(tileSize))],
        sprites: [
          TileModelSprite(
            path: 'tile_random/earth_to_water.png',
            size: Vector2.all(16),
            position: Vector2(4, 1),
          ),
        ],
      ),
      MapTerrain(
        value: TILE_EARTH,
        sprites: [
          TileModelSprite(
            path: 'tile_random/earth_to_grass.png',
            size: Vector2.all(16),
            position: Vector2(1, 1),
          ),
        ],
      ),
      MapTerrain(
        value: TILE_GRASS,
        spriteRandom: [0.93, 0.05, 0.02],
        sprites: [
          TileModelSprite(
            path: 'tile_random/grass_types.png',
            size: Vector2.all(16),
          ),
          TileModelSprite(
            path: 'tile_random/grass_types.png',
            size: Vector2.all(16),
            position: Vector2(1, 0),
          ),
          TileModelSprite(
            path: 'tile_random/grass_types.png',
            size: Vector2.all(16),
            position: Vector2(2, 0),
          ),
        ],
      ),
      MapTerrainCorners(
        value: TILE_EARTH,
        to: TILE_WATER,
        spriteSheet: TerrainSpriteSheet.create(
          'tile_random/earth_to_water.png',
          Vector2.all(16),
        ),
      ),
      MapTerrainCorners(
        value: TILE_EARTH,
        to: TILE_GRASS,
        spriteSheet: TerrainSpriteSheet.create(
          'tile_random/earth_to_grass.png',
          Vector2.all(16),
        ),
      ),
    ];
  }
}
