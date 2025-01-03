import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/random_map/decoration/tree.dart';
import 'package:example/pages/mini_games/random_map/noise_generator.dart';
import 'package:example/pages/mini_games/random_map/player/pirate.dart';
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
class MapGenerated {
  final GameMap map;
  final Player player;
  final List<GameComponent> components;

  MapGenerated(this.map, this.player, this.components);
}

class MapGenerator {
  static const double tileWater = 0;
  static const double tileSand = 1;
  static const double tileGrass = 2;
  final double tileSize;
  final Vector2 size;
  final List<GameComponent> _compList = [];
  Vector2 _playerPosition = Vector2.zero();

  MapGenerator(this.size, this.tileSize);

  Future<MapGenerated> buildMap() async {
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

    _createTreesAndPlayerPosition(matrix);

    final map = MatrixMapGenerator.generate(
      layers: [
        MatrixLayer(matrix: matrix),
      ],
      builder: _buildTerrainBuilder().build,
    );

    return MapGenerated(
      map,
      Pirate(position: _playerPosition),
      _compList,
    );
  }

  TerrainBuilder _buildTerrainBuilder() {
    return TerrainBuilder(
      tileSize: tileSize,
      terrainList: [
        MapTerrain(
          value: tileWater,
          collisionOnlyCloseCorners: true,
          collisionsBuilder: () =>
              [RectangleHitbox(size: Vector2.all(tileSize))],
          sprites: [
            TileSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(0, 1),
            ),
          ],
        ),
        MapTerrain(
          value: tileSand,
          sprites: [
            TileSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(0, 2),
            ),
          ],
        ),
        MapTerrain(
          value: tileGrass,
          spritesProportion: [0.93, 0.05, 0.02],
          sprites: [
            TileSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
            ),
            TileSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(1, 0),
            ),
            TileSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(2, 0),
            ),
          ],
        ),
        MapTerrainCorners(
          value: tileSand,
          to: tileWater,
          spriteSheet: TerrainSpriteSheet.create(
            path: 'tile_random/earth_to_water.png',
            tileSize: Vector2.all(16),
          ),
        ),
        MapTerrainCorners(
          value: tileSand,
          to: tileGrass,
          spriteSheet: TerrainSpriteSheet.create(
            path: 'tile_random/earth_to_grass.png',
            tileSize: Vector2.all(16),
          ),
        ),
      ],
    );
  }

  void _createTreesAndPlayerPosition(List<List<double>> matrix) {
    int width = matrix.length;
    int height = matrix.first.length;
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        if (_playerPosition == Vector2.zero() &&
            x > width / 2 &&
            matrix[x][y] == tileGrass) {
          _playerPosition = Vector2(x * tileSize, y * tileSize);
        }
        if (verifyIfAddTree(x, y, matrix)) {
          _compList.add(Tree(Vector2(x * tileSize, y * tileSize)));
        }
      }
    }
  }

  bool verifyIfAddTree(int x, int y, List<List<double>> matrix) {
    bool terrainIsGrass =
        ((x % 5 == 0 && y % 3 == 0) || (x % 7 == 0 && y % 5 == 0)) &&
            matrix[x][y] == tileGrass;

    bool baseTreeInGrass = false;
    if (x + 3 < matrix.length && y + 3 < matrix.first.length) {
      baseTreeInGrass = matrix[x + 3][y + 3] == tileGrass;
    }

    bool randomFactor = Random().nextDouble() > 0.5;
    return terrainIsGrass && baseTreeInGrass && randomFactor;
  }
}
