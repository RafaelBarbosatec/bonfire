import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
/// on 31/05/22

List<List<double>> generateNoise(Map<String, dynamic> data) {
  final original = noise2(
    data['w'],
    data['h'],
    seed: data['seed'],
    frequency: data['frequency'],
    noiseType: data['noiseType'],
    cellularDistanceFunction: data['cellularDistanceFunction'],
  );
  int width = original.first.length;
  int height = original.length;
  List<List<double>> newMatrix = List<List<double>>.generate(
      width, (_) => List<double>.generate(height, (_) => .0));
  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      double newValue = 0;
      if (original[x][y] > -0.35) {
        newValue = 0;
      }

      if (original[x][y] > -0.1) {
        newValue = 1;
      }

      if (original[x][y] > 0) {
        newValue = 2;
      }
      newMatrix[x][y] = newValue;
    }
  }
  return newMatrix;
}

class RandomMap extends StatefulWidget {
  final Vector2 size;
  const RandomMap({Key? key, required this.size}) : super(key: key);

  @override
  State<RandomMap> createState() => _RandomMapState();
}

class _RandomMapState extends State<RandomMap> {
  TerrainBuilder? terrainBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      DungeonMap.tileSize =
          max(constraints.maxHeight, constraints.maxWidth) / (kIsWeb ? 25 : 22);
      _buildTerrainBuilder(DungeonMap.tileSize);
      return BonfireWidget(
        joystick: Joystick(
          directional: JoystickDirectional(
            spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
            spriteKnobDirectional: Sprite.load('joystick_knob.png'),
            size: 100,
            isFixed: false,
          ),
        ),
        cameraConfig: CameraConfig(
          moveOnlyMapArea: true,
        ),
        map: _buildMap(),
      );
    });
  }

  Future<MapGame> _buildMap() async {
    final matrix = await compute(
      generateNoise,
      {
        'h': widget.size.y.toInt(),
        'w': widget.size.x.toInt(),
        'seed': Random().nextInt(2000),
        'frequency': 0.02,
        'noiseType': NoiseType.PerlinFractal,
        'cellularDistanceFunction': CellularDistanceFunction.Natural,
      },
    );

    return MatrixMapGenerator.generate(
      matrix: matrix,
      builder: (prop) {
        return terrainBuilder!.build(prop);
        Color? color = Colors.blue[900];
        if (prop.value == 0) {
          color = Colors.blue;
        }

        if (prop.value == 1) {
          color = Colors.orangeAccent;
        }

        if (prop.value == 2) {
          color = Colors.green;
        }

        // if (prop.value > 0.35) {
        //   color = Colors.white;
        // }
        return TileModel(
          x: prop.position.x,
          y: prop.position.y,
          width: DungeonMap.tileSize,
          height: DungeonMap.tileSize,
          color: color,
        );
      },
    );
  }

  void _buildTerrainBuilder(double tileSize) {
    if (terrainBuilder != null) {
      return;
    }
    terrainBuilder = TerrainBuilder(
      tileSize: tileSize,
      terrainList: [
        MapTerrain(
          value: 0,
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
          sprites: [
            TileModelSprite(
              path: 'tile_random/earth_to_grass.png',
              width: 16,
              height: 16,
              x: 4,
              y: 1,
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
      ],
    );
  }
}
