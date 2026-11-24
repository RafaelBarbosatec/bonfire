import 'dart:math' as math;
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/base/layer.dart';

export 'package:bonfire/map/pixel_tileset/pixel_art.dart';
export 'package:bonfire/map/pixel_tileset/pixel_palette.dart';
export 'package:bonfire/map/pixel_tileset/pixel_tile.dart';

/// A tileset whose tiles are pixel art described entirely in code (see
/// [PixelArt]/[PixelTile]), with no image asset involved.
///
/// On construction, [PixelTileset] packs every tile/frame into a single
/// atlas image generated at runtime (`dart:ui` `Canvas`/`Picture`) and
/// registers it into [Flame.images], so the rest of the map pipeline
/// (`Tile`, `TileSprite`, `TilelAnimation`, `TileComponent`...) works exactly
/// as it would with a loaded spritesheet - no `await` needed to start using
/// it.
///
/// Basic usage:
///
/// ```dart
/// final tileset = PixelTileset(
///   tileSize: 8,
///   palette: {
///     'g': Color(0xFF4CAF50),
///     'G': Color(0xFF2E7D32),
///     'd': Color(0xFF8D6E63),
///   },
///   tiles: {
///     'grass': PixelTile.single(PixelArt.rows([
///       'gggggggg',
///       'gGggggGg',
///       'gggggggg',
///       'gggGgggg',
///       'gggggggg',
///       'ggggggGg',
///       'gggggggg',
///       'gggggggg',
///     ])),
///     'dirt': PixelTile.single(PixelArt.rows([
///       'dddddddd',
///       'dddddddd',
///       'dddddddd',
///       'dddddddd',
///       'dddddddd',
///       'dddddddd',
///       'dddddddd',
///       'dddddddd',
///     ]), collision: true),
///   },
/// );
///
/// final map = tileset.worldMapFromAscii(
///   legend: {'#': 'dirt', '.': 'grass'},
///   rows: [
///     '##########',
///     '#........#',
///     '#........#',
///     '##########',
///   ],
/// );
/// ```
class PixelTileset {
  /// Size (width and height, in world units) of every tile produced by this
  /// tileset. All [PixelArt] used by [tiles] must have this exact size (in
  /// "pixels", i.e. characters per row/number of rows).
  final double tileSize;

  /// Maps pixel codes (used inside [PixelArt] rows) to colors.
  final PixelPalette palette;

  /// The named tiles available in this tileset.
  final Map<String, PixelTile> tiles;

  /// Key under which the generated atlas image is registered in
  /// [Flame.images]. Deterministically derived from the tileset content, so
  /// rebuilding an identical [PixelTileset] (e.g. on hot reload) reuses the
  /// same cached image instead of leaking a new one.
  late final String imageKey;

  late final int _columns;
  late final int _rows;
  final Map<String, List<Vector2>> _frameCells = {};
  final Map<String, List<TileSprite>> _frameSprites = {};
  final Map<String, TileSprite> _spriteByCell = {};
  final Map<String, TilelAnimation> _animations = {};

  PixelTileset({
    required this.tileSize,
    required this.palette,
    required this.tiles,
  }) {
    if (tiles.isEmpty) {
      throw ArgumentError('PixelTileset: `tiles` cannot be empty.');
    }
    _validateFrameSizes();
    _build();
  }

  /// Size (in world units) of the generated atlas image.
  Vector2 get atlasSize => Vector2(
        _columns * tileSize,
        _rows * tileSize,
      );

  void _validateFrameSizes() {
    final expected = tileSize.round();
    for (final entry in tiles.entries) {
      for (var i = 0; i < entry.value.frames.length; i++) {
        final art = entry.value.frames[i];
        if (art.width != expected || art.height != expected) {
          throw ArgumentError(
            'PixelTileset: tile "${entry.key}"${entry.value.isAnimated ? ' (frame $i)' : ''} '
            'has size ${art.width}x${art.height}, but tileSize is '
            '$expected x $expected. Every PixelArt in a PixelTileset must '
            'match `tileSize`.',
          );
        }
      }
    }
  }

  void _build() {
    final entries = <_AtlasEntry>[
      for (final tileEntry in tiles.entries)
        for (var i = 0; i < tileEntry.value.frames.length; i++)
          _AtlasEntry(tileEntry.key, i, tileEntry.value.frames[i]),
    ];

    // Several tile names can share the same pixel art (or an animation can
    // repeat a frame). Paint each unique art once and point every name/frame at
    // that cell instead of duplicating it in the atlas.
    final uniqueEntries = <_AtlasEntry>[];
    final cellByArt = <String, int>{};
    final cellIndexes = <int>[];
    for (final entry in entries) {
      final artKey = entry.art.rows.join('\n');
      final index = cellByArt.putIfAbsent(artKey, () {
        uniqueEntries.add(entry);
        return uniqueEntries.length - 1;
      });
      cellIndexes.add(index);
    }

    _columns = math.sqrt(uniqueEntries.length).ceil();
    _rows = (uniqueEntries.length / _columns).ceil();

    imageKey = 'pixel_tileset/${_contentHash(uniqueEntries)}';

    for (var index = 0; index < entries.length; index++) {
      final cellIndex = cellIndexes[index];
      final cell = Vector2(
        (cellIndex % _columns).toDouble(),
        (cellIndex ~/ _columns).toDouble(),
      );
      (_frameCells[entries[index].name] ??= []).add(cell);
    }

    if (Flame.images.containsKey(imageKey)) {
      return;
    }

    final tileSizeInt = tileSize.round();
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    for (var index = 0; index < uniqueEntries.length; index++) {
      final entry = uniqueEntries[index];
      final col = index % _columns;
      final row = index ~/ _columns;
      entry.art.paint(
        canvas,
        Offset(
          (col * tileSizeInt).toDouble(),
          (row * tileSizeInt).toDouble(),
        ),
        palette,
        ownerName: entry.frameIndex == 0
            ? entry.name
            : '${entry.name} (frame ${entry.frameIndex})',
      );
    }
    final picture = recorder.endRecording();
    final image = picture.toImageSync(
      _columns * tileSizeInt,
      _rows * tileSizeInt,
    );
    Flame.images.add(imageKey, image);
  }

  String _contentHash(List<_AtlasEntry> entries) {
    final buffer = StringBuffer()..write(tileSize);
    for (final code in palette.keys.toList()..sort()) {
      buffer
        ..write('|')
        ..write(code)
        ..write(':')
        ..write(palette[code]!.toARGB32());
    }
    for (final entry in entries) {
      buffer
        ..write('#')
        ..write(entry.name)
        ..write(':')
        ..write(entry.frameIndex)
        ..write(':')
        ..write(entry.art.rows.join('\n'));
    }
    return _fnv1a32(buffer.toString());
  }

  static String _fnv1a32(String input) {
    const fnvPrime = 0x01000193;
    var hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash = ((hash ^ unit) * fnvPrime) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  PixelTile _tileOf(String name) {
    final tile = tiles[name];
    if (tile == null) {
      throw ArgumentError(
        'PixelTileset: unknown tile "$name". '
        'Known tiles: ${tiles.keys.join(', ')}.',
      );
    }
    return tile;
  }

  /// Returns the [TileSprite] for the given [frame] (defaults to the first
  /// one) of the tile named [name].
  ///
  /// The returned instance is shared by every [Tile] built for that tile name:
  /// [TileSprite] is a stateless descriptor (path, atlas position and size) and
  /// [Tile.getTile] only reads it, so a map with thousands of repeated tiles
  /// does not need thousands of wrappers.
  TileSprite sprite(String name, {int frame = 0}) {
    final sprites = _spritesOf(name);
    if (frame < 0 || frame >= sprites.length) {
      throw ArgumentError(
        'PixelTileset.sprite: tile "$name" has ${sprites.length} frame(s), '
        'frame $frame is out of range.',
      );
    }
    return sprites[frame];
  }

  /// Returns the [TilelAnimation] for the tile named [name]. Throws if that
  /// tile only has a single frame (use [sprite] instead).
  TilelAnimation animation(String name) {
    final pixelTile = _tileOf(name);
    if (!pixelTile.isAnimated) {
      throw ArgumentError(
        'PixelTileset.animation: tile "$name" has a single frame. '
        'Use `sprite("$name")` instead.',
      );
    }
    return _animations.putIfAbsent(
      name,
      () => TilelAnimation(
        stepTime: pixelTile.stepTime,
        // The cached list is shared between callers, so keep the descriptor's
        // list independent.
        frames: List<TileSprite>.of(_spritesOf(name)),
      ),
    );
  }

  List<TileSprite> _spritesOf(String name) {
    final cached = _frameSprites[name];
    if (cached != null) return cached;

    final cells = _frameCellsOf(name);
    return _frameSprites[name] = [
      for (final cell in cells) _spriteAt(cell),
    ];
  }

  TileSprite _spriteAt(Vector2 cell) {
    final key = '${cell.x}/${cell.y}';
    return _spriteByCell.putIfAbsent(
      key,
      () => TileSprite(
        path: imageKey,
        position: cell,
        size: Vector2.all(tileSize),
      ),
    );
  }

  List<Vector2> _frameCellsOf(String name) {
    _tileOf(name);
    return _frameCells[name]!;
  }

  /// Builds a ready-to-use [Tile] for the tile named [name] at map position
  /// ([x], [y]), picking a static sprite or an animation automatically.
  ///
  /// `collisions`, `tileClass` and `properties` default to whatever was set
  /// on the corresponding [PixelTile], but can be overridden per call.
  Tile tile({
    required double x,
    required double y,
    required String name,
    double? width,
    double? height,
    double offsetX = 0,
    double offsetY = 0,
    double angle = 0,
    double opacity = 1.0,
    bool isFlipVertical = false,
    bool isFlipHorizontal = false,
    List<ShapeHitbox>? collisions,
    String? tileClass,
    Map<String, dynamic>? properties,
    Color? color,
  }) {
    final pixelTile = _tileOf(name);
    final resolvedCollisions = collisions ??
        (pixelTile.collision
            ? [RectangleHitbox(size: Vector2.all(tileSize))]
            : null);

    return Tile(
      x: x,
      y: y,
      width: width ?? tileSize,
      height: height ?? tileSize,
      offsetX: offsetX,
      offsetY: offsetY,
      angle: angle,
      opacity: opacity,
      isFlipVertical: isFlipVertical,
      isFlipHorizontal: isFlipHorizontal,
      sprite: pixelTile.isAnimated ? null : sprite(name),
      animation: pixelTile.isAnimated ? animation(name) : null,
      collisions: resolvedCollisions,
      tileClass: tileClass ?? pixelTile.tileClass,
      properties: properties ?? pixelTile.properties,
      color: color,
    );
  }

  /// Builds a [Layer] from an ASCII level layout: [rows] is read top to
  /// bottom, each character looked up in [legend] to find which tile (by
  /// name, see [tiles]) should be placed at that cell. `'.'` means "no tile"
  /// unless explicitly present in [legend].
  Layer layerFromAscii({
    required Map<String, String> legend,
    required List<String> rows,
    int? id,
    String? name,
    String? layerClass,
    bool visible = true,
    Vector2? position,
    Vector2? offset,
    double opacity = 1,
    Map<String, dynamic>? properties,
    int priority = 0,
  }) {
    if (rows.isEmpty) {
      throw ArgumentError('layerFromAscii: `rows` cannot be empty.');
    }
    final width = rows.first.length;
    final asciiTiles = <Tile>[];
    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      if (row.length != width) {
        throw ArgumentError(
          'layerFromAscii: all rows must have the same length. '
          'Row 0 has length $width but row $y ("$row") has length '
          '${row.length}.',
        );
      }
      for (var x = 0; x < width; x++) {
        final code = row[x];
        final tileName = legend[code];
        if (tileName == null) {
          if (code == '.') {
            continue;
          }
          throw ArgumentError(
            'layerFromAscii: unknown legend code "$code" at row $y, column '
            '$x. Known codes: ${legend.keys.join(', ')} (and "." for an '
            'empty cell).',
          );
        }
        asciiTiles.add(tile(x: x.toDouble(), y: y.toDouble(), name: tileName));
      }
    }

    return Layer(
      id: id,
      tiles: asciiTiles,
      name: name,
      layerClass: layerClass,
      visible: visible,
      position: position,
      offset: offset,
      opacity: opacity,
      properties: properties,
      priority: priority,
    );
  }

  /// Convenience around [layerFromAscii] that wraps the resulting [Layer]
  /// into a ready-to-use single-layer [WorldMap].
  WorldMap worldMapFromAscii({
    required Map<String, String> legend,
    required List<String> rows,
    double tileSizeToUpdate = 0,
    int? id,
    String? name,
    String? layerClass,
    bool visible = true,
    Vector2? position,
    Vector2? offset,
    double opacity = 1,
    Map<String, dynamic>? properties,
    int priority = 0,
  }) {
    final layer = layerFromAscii(
      legend: legend,
      rows: rows,
      id: id,
      name: name,
      layerClass: layerClass,
      visible: visible,
      position: position,
      offset: offset,
      opacity: opacity,
      properties: properties,
      priority: priority,
    );
    return WorldMap([layer], tileSizeToUpdate: tileSizeToUpdate);
  }

  /// Removes the generated atlas image from [Flame.images].
  ///
  /// Only needed if you build many distinct (non-reusable) [PixelTileset]s
  /// over the lifetime of the app and want to free the GPU texture; a
  /// tileset kept around for the lifetime of a game/level does not need
  /// this.
  void dispose() {
    Flame.images.clear(imageKey);
  }
}

class _AtlasEntry {
  final String name;
  final int frameIndex;
  final PixelArt art;

  _AtlasEntry(this.name, this.frameIndex, this.art);
}
