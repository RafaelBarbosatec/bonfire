import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';

const _red = Color(0xFFFF0000);
const _blue = Color(0xFF0000FF);

/// Reads the RGBA bytes of pixel ([x], [y]) from [image].
Future<List<int>> _pixelAt(ui.Image image, int x, int y) async {
  final bytes = await image.toByteData();
  final data = bytes!.buffer.asUint8List();
  final index = (y * image.width + x) * 4;
  return data.sublist(index, index + 4);
}

void main() {
  group('PixelArt', () {
    test('rows() validates that every row has the same length', () {
      expect(
        () => PixelArt.rows(['aa', 'a']),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            'message',
            contains('all rows must have the same length'),
          ),
        ),
      );
    });

    test('rows() rejects an empty list', () {
      expect(() => PixelArt.rows([]), throwsArgumentError);
    });

    test('computes width/height from the given rows', () {
      final art = PixelArt.rows(['abc', 'def']);
      expect(art.width, 3);
      expect(art.height, 2);
    });
  });

  group('PixelTileset atlas generation', () {
    test('paints each tile into its own atlas cell', () async {
      final tileset = PixelTileset(
        tileSize: 2,
        palette: {'r': _red, 'b': _blue},
        tiles: {
          'solid': PixelTile.single(PixelArt.rows(['rr', 'rr'])),
          'half': PixelTile.single(PixelArt.rows(['rb', '.r'])),
        },
      );

      expect(Flame.images.containsKey(tileset.imageKey), isTrue);
      final image = Flame.images.fromCache(tileset.imageKey);

      // 2 tiles of 1 frame each => 2 cells => 2 columns x 1 row.
      expect(image.width, 4);
      expect(image.height, 2);
      expect(tileset.atlasSize, Vector2(4, 2));

      // 'solid' -> cell (0, 0): fully red.
      expect(await _pixelAt(image, 0, 0), [255, 0, 0, 255]);
      expect(await _pixelAt(image, 1, 1), [255, 0, 0, 255]);

      // 'half' -> cell (1, 0), pixel offset (2, 0).
      expect(await _pixelAt(image, 2, 0), [255, 0, 0, 255]); // 'r'
      expect(await _pixelAt(image, 3, 0), [0, 0, 255, 255]); // 'b'
      expect(await _pixelAt(image, 3, 1), [255, 0, 0, 255]); // 'r'
      expect(await _pixelAt(image, 2, 1), [0, 0, 0, 0]); // '.' transparent
    });

    test('sprite() returns a TileSprite pointing at the right atlas cell', () {
      final tileset = PixelTileset(
        tileSize: 2,
        palette: {'r': _red, 'b': _blue},
        tiles: {
          'solid': PixelTile.single(PixelArt.rows(['rr', 'rr'])),
          'half': PixelTile.single(PixelArt.rows(['rb', '.r'])),
        },
      );

      final solid = tileset.sprite('solid');
      expect(solid.path, tileset.imageKey);
      expect(solid.position, Vector2(0, 0));
      expect(solid.size, Vector2(2, 2));

      final half = tileset.sprite('half');
      expect(half.position, Vector2(1, 0));
    });

    test('sprite() throws for an unknown tile name', () {
      final tileset = PixelTileset(
        tileSize: 2,
        palette: {'r': _red},
        tiles: {
          'solid': PixelTile.single(PixelArt.rows(['rr', 'rr']))
        },
      );

      expect(
        () => tileset.sprite('missing'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            'message',
            contains('Known tiles: solid'),
          ),
        ),
      );
    });

    test(
      'paint() throws a descriptive error for an unknown pixel code',
      () {
        expect(
          () => PixelTileset(
            tileSize: 2,
            palette: {'r': _red},
            tiles: {
              'broken': PixelTile.single(PixelArt.rows(['rx', 'rr'])),
            },
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message.toString(),
              'message',
              allOf(
                contains('Unknown pixel code "x"'),
                contains('broken'),
              ),
            ),
          ),
        );
      },
    );

    test('rejects a PixelArt whose size does not match tileSize', () {
      expect(
        () => PixelTileset(
          tileSize: 4,
          palette: {'r': _red},
          tiles: {
            'wrongSize': PixelTile.single(PixelArt.rows(['rr', 'rr'])),
          },
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            'message',
            contains('wrongSize'),
          ),
        ),
      );
    });

    test('rejects an empty `tiles` map', () {
      expect(
        () => PixelTileset(tileSize: 2, palette: const {}, tiles: const {}),
        throwsArgumentError,
      );
    });

    test('identical content reuses the same cached atlas key', () {
      PixelTileset build() => PixelTileset(
            tileSize: 2,
            palette: {'r': _red},
            tiles: {
              'solid': PixelTile.single(PixelArt.rows(['rr', 'rr'])),
            },
          );

      final first = build();
      final second = build();
      expect(first.imageKey, second.imageKey);
    });

    test('different content produces a different atlas key', () {
      final first = PixelTileset(
        tileSize: 2,
        palette: {'r': _red},
        tiles: {
          'solid': PixelTile.single(PixelArt.rows(['rr', 'rr']))
        },
      );
      final second = PixelTileset(
        tileSize: 2,
        palette: {'r': _blue},
        tiles: {
          'solid': PixelTile.single(PixelArt.rows(['rr', 'rr']))
        },
      );
      expect(first.imageKey, isNot(second.imageKey));
    });

    test('dispose() removes the atlas image from the Flame cache', () {
      final tileset = PixelTileset(
        tileSize: 2,
        palette: {'r': _red},
        tiles: {
          'solid': PixelTile.single(PixelArt.rows(['rr', 'rr']))
        },
      );
      expect(Flame.images.containsKey(tileset.imageKey), isTrue);
      tileset.dispose();
      expect(Flame.images.containsKey(tileset.imageKey), isFalse);
    });
  });

  group('PixelTileset animated tiles', () {
    PixelTileset buildAnimatedTileset() {
      return PixelTileset(
        tileSize: 2,
        palette: {'b': _blue, 'r': _red},
        tiles: {
          'water': PixelTile.animated(
            [
              PixelArt.rows(['bb', 'bb']),
              PixelArt.rows(['rr', 'rr']),
            ],
            stepTime: 0.2,
          ),
        },
      );
    }

    test('animation() returns one frame per PixelArt', () {
      final tileset = buildAnimatedTileset();
      final animation = tileset.animation('water');

      expect(animation.stepTime, 0.2);
      expect(animation.frames, hasLength(2));
      expect(animation.frames[0].position, Vector2(0, 0));
      expect(animation.frames[1].position, Vector2(1, 0));
    });

    test('sprite() can still target a specific frame', () {
      final tileset = buildAnimatedTileset();
      expect(tileset.sprite('water').position, Vector2(0, 0));
      expect(tileset.sprite('water', frame: 1).position, Vector2(1, 0));
      expect(() => tileset.sprite('water', frame: 2), throwsArgumentError);
    });

    test('animation() throws for a tile with a single frame', () {
      final tileset = PixelTileset(
        tileSize: 2,
        palette: {'r': _red},
        tiles: {
          'solid': PixelTile.single(PixelArt.rows(['rr', 'rr']))
        },
      );
      expect(
        () => tileset.animation('solid'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            'message',
            contains('has a single frame'),
          ),
        ),
      );
    });
  });

  group('PixelTileset.tile()', () {
    test('builds a Tile with the resolved sprite/size/position', () {
      final tileset = PixelTileset(
        tileSize: 2,
        palette: {'r': _red},
        tiles: {
          'solid': PixelTile.single(PixelArt.rows(['rr', 'rr']))
        },
      );

      final tile = tileset.tile(x: 3, y: 5, name: 'solid');
      expect(tile.x, 3);
      expect(tile.y, 5);
      expect(tile.width, 2);
      expect(tile.height, 2);
      expect(tile.sprite?.path, tileset.imageKey);
      expect(tile.collisions, isNull);
    });

    test('adds a full-tile RectangleHitbox when PixelTile.collision is true',
        () {
      final tileset = PixelTileset(
        tileSize: 4,
        palette: {'r': _red},
        tiles: {
          'wall': PixelTile.single(
            PixelArt.rows(['rrrr', 'rrrr', 'rrrr', 'rrrr']),
            collision: true,
          ),
        },
      );

      final tile = tileset.tile(x: 0, y: 0, name: 'wall');
      expect(tile.collisions, hasLength(1));
      final hitbox = tile.collisions!.first as RectangleHitbox;
      expect(hitbox.size, Vector2(4, 4));
    });

    test('an explicit `collisions` override wins over PixelTile.collision', () {
      final tileset = PixelTileset(
        tileSize: 2,
        palette: {'r': _red},
        tiles: {
          'wall': PixelTile.single(
            PixelArt.rows(['rr', 'rr']),
            collision: true,
          ),
        },
      );

      final tile = tileset.tile(x: 0, y: 0, name: 'wall', collisions: []);
      expect(tile.collisions, isEmpty);
    });

    test('uses the animation automatically for animated tiles', () {
      final tileset = PixelTileset(
        tileSize: 2,
        palette: {'b': _blue},
        tiles: {
          'water': PixelTile.animated(
            [
              PixelArt.rows(['bb', 'bb']),
              PixelArt.rows(['bb', 'bb']),
            ],
            stepTime: 0.1,
          ),
        },
      );

      final tile = tileset.tile(x: 0, y: 0, name: 'water');
      expect(tile.sprite, isNull);
      expect(tile.animation, isNotNull);
      expect(tile.animation!.frames, hasLength(2));
    });
  });

  group('PixelTileset ascii builders', () {
    PixelTileset buildTileset() {
      return PixelTileset(
        tileSize: 2,
        palette: {'r': _red},
        tiles: {
          'wall': PixelTile.single(
            PixelArt.rows(['rr', 'rr']),
            collision: true,
          ),
        },
      );
    }

    test('layerFromAscii places tiles at the right coordinates', () {
      final tileset = buildTileset();
      final layer = tileset.layerFromAscii(
        legend: {'#': 'wall'},
        rows: ['#.', '.#'],
      );

      expect(layer.tiles, hasLength(2));
      final positions = layer.tiles.map((t) => Vector2(t.x, t.y)).toSet();
      expect(positions, {Vector2(0, 0), Vector2(1, 1)});
      for (final tile in layer.tiles) {
        expect(tile.collisions, hasLength(1));
      }
    });

    test('"." means an empty cell unless present in the legend', () {
      final tileset = buildTileset();
      final layer = tileset.layerFromAscii(
        legend: {'#': 'wall', '.': 'wall'},
        rows: ['#.'],
      );
      expect(layer.tiles, hasLength(2));
    });

    test('throws a descriptive error for an unknown legend code', () {
      final tileset = buildTileset();
      expect(
        () => tileset.layerFromAscii(legend: {'#': 'wall'}, rows: ['#?']),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            'message',
            contains('unknown legend code "?"'),
          ),
        ),
      );
    });

    test('throws when ascii rows have inconsistent lengths', () {
      final tileset = buildTileset();
      expect(
        () => tileset.layerFromAscii(
          legend: {'#': 'wall'},
          rows: ['##', '#'],
        ),
        throwsArgumentError,
      );
    });

    test('worldMapFromAscii wraps a single layer into a WorldMap', () {
      final tileset = buildTileset();
      final map = tileset.worldMapFromAscii(
        legend: {'#': 'wall'},
        rows: ['##', '##'],
      );

      expect(map.layers, hasLength(1));
      expect(map.layers.first.tiles, hasLength(4));
    });
  });
}
