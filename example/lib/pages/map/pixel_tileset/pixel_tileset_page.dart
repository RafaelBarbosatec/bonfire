import 'package:bonfire/bonfire.dart';
import 'package:example/pages/map/pixel_tileset/pixel_hero.dart';
import 'package:flutter/material.dart';

/// Shows how to build a whole, good-looking level - including the player -
/// with [PixelTileset], without loading a single image asset.
///
/// Every tile (and the hero) is pixel art described in plain Dart code: a
/// color [PixelPalette], and a grid of palette codes per tile ([PixelArt]).
/// [PixelTileset] packs all of that into one generated atlas image at
/// runtime and the map layout itself is just ASCII art
/// (`PixelTileset.worldMapFromAscii`).
///
/// This is particularly handy when you (or an AI agent) want to prototype or
/// ship a good-looking level purely from code/text, with no image
/// pipeline/editor involved.
class PixelTilesetPage extends StatelessWidget {
  const PixelTilesetPage({super.key});

  static const double tileSize = 16;

  @override
  Widget build(BuildContext context) {
    final tileset = _buildTileset();

    return BonfireWidget(
      map: tileset.worldMapFromAscii(
        legend: const {
          '#': 'wall',
          '.': 'grass',
          '=': 'path',
          '~': 'water',
        },
        rows: const [
          '################',
          '#..............#',
          '#..==========..#',
          '#..=........=..#',
          '#..=..~~~~..=..#',
          '#..=..~~~~..=..#',
          '#..=..~~~~..=..#',
          '#..=........=..#',
          '#..==========..#',
          '#..............#',
          '#..............#',
          '################',
        ],
      ),
      player: PixelHero(
        position: Vector2(tileSize * 2, tileSize * 2),
        tileSize: tileSize,
        sprite: tileset.sprite('hero').getSprite(),
      ),
      playerControllers: [
        Joystick(directional: JoystickDirectional()),
        Keyboard(),
      ],
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 16),
      ),
      backgroundColor: const Color(0xFF1B1B1B),
    );
  }

  /// Builds the whole tileset: palette + tiles, all described as pixel art
  /// in code (see [_grid] below for the tiny helper used to generate each
  /// tile's rows).
  PixelTileset _buildTileset() {
    const palette = <String, Color>{
      'g': Color(0xFF4CAF50), // grass
      'G': Color(0xFF66BB6A), // grass speck
      'd': Color(0xFFA1887F), // dirt path
      'D': Color(0xFF8D6E63), // dirt pebble
      'w': Color(0xFF1E88E5), // water
      'W': Color(0xFF90CAF9), // water highlight
      's': Color(0xFF9E9E9E), // wall stone
      'm': Color(0xFF616161), // wall mortar
      'h': Color(0xFFFFCC80), // hero skin
      'o': Color(0xFFEF6C00), // hero outline
      'k': Color(0xFF3E2723), // hero eyes
    };

    return PixelTileset(
      tileSize: tileSize,
      palette: palette,
      tiles: {
        'grass': PixelTile.single(
          PixelArt.rows(
            _grid((x, y) => (x * 7 + y * 13) % 23 == 0 ? 'G' : 'g'),
          ),
        ),
        'path': PixelTile.single(
          PixelArt.rows(
            _grid((x, y) => (x * 5 + y * 11) % 17 == 0 ? 'D' : 'd'),
          ),
        ),
        'water': PixelTile.animated(
          [
            PixelArt.rows(_grid((x, y) => (x + y) % 6 < 2 ? 'W' : 'w')),
            PixelArt.rows(_grid((x, y) => (x + y + 3) % 6 < 2 ? 'W' : 'w')),
          ],
          stepTime: 0.4,
        ),
        'wall': PixelTile.single(
          PixelArt.rows(
            _grid(
              (x, y) =>
                  (y % 8 == 0) || ((x + (y ~/ 8) * 4) % 8 == 0) ? 'm' : 's',
            ),
          ),
          collision: true,
        ),
        'hero': PixelTile.single(PixelArt.rows(_grid(_heroPixel))),
      },
    );
  }

  /// Builds a square [tileSize]x[tileSize] grid of pixel codes using
  /// [codeAt].
  List<String> _grid(String Function(int x, int y) codeAt) {
    final size = tileSize.round();
    return List.generate(
      size,
      (y) => List.generate(size, (x) => codeAt(x, y)).join(),
    );
  }

  /// A small round character: skin fill, darker outline, two eyes.
  String _heroPixel(int x, int y) {
    final size = tileSize.round();
    final center = (size - 1) / 2;
    final dx = x - center;
    final dy = y - center;
    final distanceSquared = dx * dx + dy * dy;
    final radius = center - 0.5;
    if (distanceSquared > radius * radius) {
      return '.';
    }
    if (y == (size * 0.35).round() &&
        (x == (size * 0.3).round() || x == (size * 0.65).round())) {
      return 'k';
    }
    if (distanceSquared > (radius - 1.5) * (radius - 1.5)) {
      return 'o';
    }
    return 'h';
  }
}
