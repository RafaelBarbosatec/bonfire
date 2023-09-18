// ignore_for_file: non_constant_identifier_names

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class TerrainBuilderPage extends StatelessWidget {
  final double TILE_WATER = 0;
  final double TILE_SAND = 1;
  final double TILE_GRASS = 2;
  const TerrainBuilderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(directional: JoystickDirectional()),
      map: MatrixMapGenerator.generate(
        matrix: [
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 1, 2, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 2, 1, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        ],
        builder: _builder,
      ),
    );
  }

  TileModel _builder(ItemMatrixProperties props) {
    return TerrainBuilder(
      tileSize: 32,
      terrainList: [
        MapTerrain(
          value: TILE_WATER,
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
          spritesProportion: [0.5, 0.5],
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
    ).build(props);
  }
}