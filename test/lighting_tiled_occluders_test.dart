import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';

class _FakeTiledReader extends WorldMapReader<TiledMap> {
  _FakeTiledReader(this.map);

  final TiledMap map;

  @override
  Future<TiledMap> readMap() async => map;

  @override
  String get basePath => '';
}

Map<String, dynamic> _mapJson({List<Map<String, dynamic>>? layers}) {
  return {
    'width': 4,
    'height': 3,
    'tilewidth': 16,
    'tileheight': 16,
    'orientation': 'orthogonal',
    'layers': layers ?? const <Map<String, dynamic>>[],
  };
}

void main() {
  group('mergeOccluderTileGrid', () {
    test('returns nothing for an empty grid', () {
      expect(
        mergeOccluderTileGrid(
          cells: const [],
          tileWidth: 16,
          tileHeight: 16,
        ),
        isEmpty,
      );
    });

    test('merges a block into a single rectangle', () {
      final rects = mergeOccluderTileGrid(
        cells: const [
          [true, true, false],
          [true, true, false],
          [false, false, false],
        ],
        tileWidth: 16,
        tileHeight: 16,
      );

      expect(rects, [const Rect.fromLTWH(0, 0, 32, 32)]);
    });

    test('merges a full row into one rectangle', () {
      final rects = mergeOccluderTileGrid(
        cells: const [
          [true, true, true, true],
        ],
        tileWidth: 8,
        tileHeight: 8,
      );

      expect(rects, [const Rect.fromLTWH(0, 0, 32, 8)]);
    });

    test('keeps an L shape as two rectangles', () {
      final rects = mergeOccluderTileGrid(
        cells: const [
          [true, false],
          [true, true],
        ],
        tileWidth: 16,
        tileHeight: 16,
      );

      expect(rects, [
        const Rect.fromLTWH(0, 0, 16, 32),
        const Rect.fromLTWH(16, 16, 16, 16),
      ]);
    });

    test('applies the layer offset', () {
      final rects = mergeOccluderTileGrid(
        cells: const [
          [true],
        ],
        tileWidth: 16,
        tileHeight: 16,
        offsetX: 32,
        offsetY: 48,
      );

      expect(rects, [const Rect.fromLTWH(32, 48, 16, 16)]);
    });
  });

  group('TiledWorldBuilder — lighting occluders', () {
    test('reads an occluder tile layer and object layer', () async {
      final map = TiledMap.fromJson(
        _mapJson(
          layers: [
            {
              'id': 1,
              'name': 'walls',
              'type': 'tilelayer',
              'class': 'lighting_occluder',
              'visible': true,
              'width': 4,
              'height': 3,
              'data': [
                1, 1, 0, 0, //
                1, 1, 0, 0, //
                0, 0, 0, 0, //
              ],
            },
            {
              'id': 2,
              'name': 'occluders',
              'type': 'objectgroup',
              'class': 'lighting_occluder',
              'visible': true,
              'objects': [
                {
                  'id': 1,
                  'name': 'wall',
                  'type': 'lighting_occluder',
                  'x': 48,
                  'y': 16,
                  'width': 16,
                  'height': 8,
                  'rotation': 0,
                  'visible': true,
                },
                {
                  'id': 2,
                  'name': 'triangle',
                  'type': 'lighting_occluder',
                  'x': 8,
                  'y': 40,
                  'width': 12,
                  'height': 10,
                  'rotation': 0,
                  'visible': true,
                  'polygon': [
                    {'x': 0, 'y': 0},
                    {'x': 12, 'y': 0},
                    {'x': 0, 'y': 10},
                  ],
                },
              ],
            },
          ],
        ),
      );

      final built = await TiledWorldBuilder(_FakeTiledReader(map)).build();

      expect(built.lightingOccluders, hasLength(3));

      // Tiles 2x2 are merged into one occluder.
      expect(
        built.lightingOccluders[0].bounds,
        const Rect.fromLTWH(0, 0, 32, 32),
      );
      expect(built.lightingOccluders[0].points, hasLength(4));

      // Rectangle object.
      expect(
        built.lightingOccluders[1].bounds,
        const Rect.fromLTWH(48, 16, 16, 8),
      );

      // Polygon object (points are relative to the object position).
      expect(
        built.lightingOccluders[2].points,
        [Vector2(8, 40), Vector2(20, 40), Vector2(8, 50)],
      );
    });

    test('does not render the occluder tile layer', () async {
      final map = TiledMap.fromJson(
        _mapJson(
          layers: [
            {
              'id': 1,
              'name': 'walls',
              'type': 'tilelayer',
              'class': 'lighting_occluder',
              'visible': true,
              'width': 2,
              'height': 1,
              'data': [1, 1],
            },
          ],
        ),
      );

      final built = await TiledWorldBuilder(_FakeTiledReader(map)).build();

      expect(built.lightingOccluders, hasLength(1));
      expect(built.map.layers, isEmpty);
    });

    test('rotates a rectangular occluder around its center', () async {
      final map = TiledMap.fromJson(
        _mapJson(
          layers: [
            {
              'id': 1,
              'name': 'occluders',
              'type': 'objectgroup',
              'class': 'lighting_occluder',
              'visible': true,
              'objects': [
                {
                  'id': 1,
                  'name': 'wall',
                  'type': 'lighting_occluder',
                  'x': 0,
                  'y': 0,
                  'width': 16,
                  'height': 8,
                  'rotation': 90,
                  'visible': true,
                },
              ],
            },
          ],
        ),
      );

      final built = await TiledWorldBuilder(_FakeTiledReader(map)).build();

      expect(built.lightingOccluders, hasLength(1));
      final bounds = built.lightingOccluders.first.bounds;
      expect(bounds.width, closeTo(8, 1e-9));
      expect(bounds.height, closeTo(16, 1e-9));
    });

    test('ignores objects from other layers', () async {
      final map = TiledMap.fromJson(
        _mapJson(
          layers: [
            {
              'id': 1,
              'name': 'decorations',
              'type': 'objectgroup',
              'visible': true,
              'objects': [
                {
                  'id': 1,
                  'name': 'tree',
                  'x': 0,
                  'y': 0,
                  'width': 16,
                  'height': 16,
                  'visible': true,
                },
              ],
            },
          ],
        ),
      );

      final built = await TiledWorldBuilder(_FakeTiledReader(map)).build();

      expect(built.lightingOccluders, isEmpty);
    });
  });
}
