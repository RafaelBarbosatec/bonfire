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
        value: 0,
        collisionOnlyCloseCorners: true,
        collisions: [
          CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
        ],
        sprites: [
          TileModelSprite(
            path: 'tile_random/earth_to_water.png',
            width: 16,
            height: 16,
            x: 4,
            y: 1,
          ),
        ],
      ),
      MapTerrain(
        value: 1,
        sprites: [
          TileModelSprite(
            path: 'tile_random/earth_to_grass.png',
            width: 16,
            height: 16,
            x: 1,
            y: 1,
          ),
        ],
      ),
      MapTerrain(
        value: 2,
        spriteRandom: [0.93, 0.05, 0.02],
        sprites: [
          TileModelSprite(
            path: 'tile_random/grass_types.png',
            width: 16,
            height: 16,
          ),
          TileModelSprite(
            path: 'tile_random/grass_types.png',
            width: 16,
            height: 16,
            x: 1,
            y: 0,
          ),
          TileModelSprite(
            path: 'tile_random/grass_types.png',
            width: 16,
            height: 16,
            x: 2,
            y: 0,
          ),
        ],
      ),
      MapTerrainCorners(
        value: 1,
        to: 0,
        spriteSheet: TerrainSpriteSheet.create(
          'tile_random/earth_to_water.png',
          Vector2(16, 16),
        ),
      ),
      MapTerrainCorners(
        value: 1,
        to: 2,
        spriteSheet: TerrainSpriteSheet.create(
          'tile_random/earth_to_grass.png',
          Vector2(16, 16),
        ),
      ),
    ];
  }
}
