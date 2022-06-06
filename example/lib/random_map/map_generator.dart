import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/random_map/decoration/tree.dart';
import 'package:example/random_map/noise_generator.dart';
import 'package:example/random_map/player/pirate.dart';
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
  static const double TILE_SAND = 1;
  static const double TILE_GRASS = 2;
  final double tileSize;
  final Vector2 size;
  List<GameComponent> _compList = [];
  Vector2 _playerPosition = Vector2.zero();
  var matrixCompleter = Completer<List<List<double>>>();

  MapGenerator(this.size, this.tileSize);

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

    _createCompsAndPlayerPosition(matrix);

    if (matrixCompleter.isCompleted) {
      matrixCompleter = Completer<List<List<double>>>();
    }
    matrixCompleter.complete(matrix);

    return MatrixMapGenerator.generate(
      matrix: matrix,
      // matrix: [
      //   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 1, 2, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 2, 1, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      // ],
      builder: _buildTerrainBuilder().build,
    );
  }

  TerrainBuilder _buildTerrainBuilder() {
    return TerrainBuilder(
      tileSize: tileSize,
      terrainList: [
        MapTerrain(
          value: TILE_WATER,
          collisionOnlyCloseCorners: true,
          collisions: [CollisionArea.rectangle(size: Vector2.all(tileSize))],
          sprites: [
            TileModelSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(0, 1),
            ),
          ],
        ),
        MapTerrain(
          value: TILE_SAND,
          sprites: [
            TileModelSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(0, 2),
            ),
          ],
        ),
        MapTerrain(
          value: TILE_GRASS,
          spritesProportion: [0.93, 0.05, 0.02],
          sprites: [
            TileModelSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
            ),
            TileModelSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(1, 0),
            ),
            TileModelSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(2, 0),
            ),
          ],
        ),
        MapTerrainCorners(
          value: TILE_SAND,
          to: TILE_WATER,
          spriteSheet: TerrainSpriteSheet.create(
            path: 'tile_random/earth_to_water.png',
            tileSize: Vector2.all(16),
          ),
        ),
        MapTerrainCorners(
          value: TILE_SAND,
          to: TILE_GRASS,
          spriteSheet: TerrainSpriteSheet.create(
            path: 'tile_random/earth_to_grass.png',
            tileSize: Vector2.all(16),
          ),
        ),
      ],
    );
  }

  Future<Player> getPlayer() async {
    await matrixCompleter.future;
    return Pirate(position: _playerPosition);
  }

  Future<List<GameComponent>> buildComponents() async {
    await matrixCompleter.future;
    return _compList;
  }

  void _createCompsAndPlayerPosition(List<List<double>> matrix) {
    int width = matrix.length;
    int height = matrix.first.length;
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        if (_playerPosition == Vector2.zero() &&
            x > width / 2 &&
            matrix[x][y] == TILE_GRASS) {
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
            matrix[x][y] == TILE_GRASS;

    bool baseTreeInGrass = false;
    try {
      baseTreeInGrass = matrix[x + 3][y + 3] == TILE_GRASS;
    } catch (e) {}

    bool randomFactor = Random().nextDouble() > 0.5;
    return terrainIsGrass && baseTreeInGrass && randomFactor;
  }
}
