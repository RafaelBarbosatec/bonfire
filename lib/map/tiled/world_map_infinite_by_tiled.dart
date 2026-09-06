import 'dart:async';
import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';

/// How an infinite map repeats its pattern.
enum InfiniteWorldMapType {
  /// Repeats on both axes (real infinite world).
  open,

  /// Repeats only vertically — the map keeps a single "column".
  vertical,

  /// Repeats only horizontally — the map keeps a single "row".
  horizontal,
}

/// A Tiled map that behaves like an infinite world.
///
/// The small Tiled map you provide is treated as a **pattern**: its tile
/// layers and object layers are repeated around the camera in a grid of
/// chunks. Chunks that are far away from the camera are unloaded again, so
/// memory stays bounded no matter how far the player walks.
///
/// Usage:
/// ```dart
/// WorldMapInfiniteByTiled(
///   WorldMapReader.fromAsset('my_pattern.tmj'),
///   type: InfiniteWorldMapType.open,
///   objectsBuilder: {'enemy': (props) => MyEnemy(props.position)},
/// )
/// ```
///
/// Notes:
/// - The origin chunk (0,0) is always kept loaded.
/// - Content that comes from **object layers** (objects, collision
///   rectangles, texts) is recreated for every chunk through
///   `TiledWorldBuilder`, so builders are invoked per chunk.
/// - Oversized / "above" decorations authored on **tile layers** are only
///   rendered on the origin chunk; prefer object layers for anything that
///   should repeat.
class WorldMapInfiniteByTiled extends WorldMap {
  final InfiniteWorldMapType type;

  /// Extra pixels around the visible area that keep chunks loaded, avoiding
  /// pop-in while the player is moving.
  final double cameraMargin;

  late final TiledWorldBuilder _builder;

  // Pattern dimensions, captured after the origin chunk is built.
  int _chunkCols = 0;
  int _chunkRows = 0;
  double _chunkWidthPx = 0;
  double _chunkHeightPx = 0;

  /// The original tiles of the origin chunk per layer component. Copies of
  /// these tiles (shifted) make every other chunk.
  final Map<TileLayerComponent, List<Tile>> _baseTilesByLayer = {};

  final Set<String> _loadedChunks = {};
  final Set<String> _requestingChunks = {};
  final Map<String, Map<TileLayerComponent, List<Tile>>> _chunkTiles = {};
  final Map<String, List<GameComponent>> _chunkComponents = {};

  bool _busy = false;
  String _lastNeededKey = '';
  double _priorityOffsetY = 0;

  WorldMapInfiniteByTiled(
    WorldMapReader<TiledMap> reader, {
    Vector2? forceTileSize,
    ValueChanged<Object>? onError,
    double sizeToUpdate = 0,
    Map<String, ObjectBuilder>? objectsBuilder,
    this.type = InfiniteWorldMapType.open,
    this.cameraMargin = 200,
  }) : super(const []) {
    this.sizeToUpdate = sizeToUpdate;
    _builder = TiledWorldBuilder(
      reader,
      forceTileSize: forceTileSize,
      onError: onError,
      sizeToUpdate: sizeToUpdate,
      objectsBuilder: objectsBuilder,
    );
  }

  /// Number of chunks currently instantiated (debugging helper).
  int get loadedChunksCount => _loadedChunks.length;

  @override
  bool get isWorldInfinite => true;

  @override
  double get renderPriorityOffsetY => _priorityOffsetY;

  @override
  Future<void> onLoad() async {
    // 1. Build the origin chunk (tile layers + object layers).
    final built = await _builder.build();
    layers = built.map.layers;

    // 2. Let WorldMap create the TileLayerComponents for the origin chunk.
    await super.onLoad();

    _initFromOrigin(built);

    // 3. The origin chunk is always alive; register its components so they
    //    can be tracked (and never duplicated).
    final originComponents = built.components ?? const <GameComponent>[];
    if (originComponents.isNotEmpty) {
      gameRef.addAll(originComponents);
    }
    for (final child in built.mapChildren ?? const <GameComponent>[]) {
      add(child);
    }
    _chunkComponents['0,0'] = originComponents;
    _loadedChunks.add('0,0');
    _refreshPriorityOffset();

    // 4. Infinite worlds need a much larger collision detection area than
    //    the origin chunk.
    gameRef.configCollisionDetection(_collisionArea());
  }

  void _initFromOrigin(WorldBuildData built) {
    for (final layer in layersComponent) {
      if (layer.tiles.isEmpty) {
        continue;
      }
      _baseTilesByLayer[layer] = List<Tile>.from(layer.tiles);
      final layerCols = math.max(1, (layer.size.x / layer.tileSize).round());
      final layerRows = math.max(1, (layer.size.y / layer.tileSize).round());
      _chunkCols = math.max(_chunkCols, layerCols);
      _chunkRows = math.max(_chunkRows, layerRows);
    }
    _chunkWidthPx = _chunkCols * tileSize;
    _chunkHeightPx = _chunkRows * tileSize;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateChunkWindow();
  }

  void _updateChunkWindow() {
    if (_chunkWidthPx <= 0 || _busy) {
      return;
    }
    final visible = gameRef.camera.visibleWorldRect;
    if (visible.isEmpty) {
      return;
    }
    final needed = _neededChunkIds(visible);
    final key = needed.join(';');
    if (key == _lastNeededKey) {
      return;
    }
    _lastNeededKey = key;
    _busy = true;
    unawaited(_syncChunks(needed));
  }

  Future<void> _syncChunks(Set<String> needed) async {
    try {
      for (final chunkId in needed) {
        if (_loadedChunks.contains(chunkId) ||
            _requestingChunks.contains(chunkId)) {
          continue;
        }
        _requestingChunks.add(chunkId);
        try {
          await _loadChunk(chunkId);
        } finally {
          _requestingChunks.remove(chunkId);
        }
      }

      final window = _windowFromIds(needed);
      for (final chunkId in _loadedChunks.toList()) {
        if (chunkId == '0,0') {
          continue;
        }
        if (_isChunkNearWindow(chunkId, window)) {
          continue;
        }
        _unloadChunk(chunkId);
      }
      _refreshPriorityOffset();
    } finally {
      _busy = false;
    }
  }

  Set<String> _neededChunkIds(Rect visible) {
    final rect = visible.inflate(cameraMargin);
    var minCx = (rect.left / _chunkWidthPx).floor();
    var maxCx = (rect.right / _chunkWidthPx).floor();
    var minCy = (rect.top / _chunkHeightPx).floor();
    var maxCy = (rect.bottom / _chunkHeightPx).floor();

    if (type == InfiniteWorldMapType.vertical) {
      minCx = maxCx = 0;
    } else if (type == InfiniteWorldMapType.horizontal) {
      minCy = maxCy = 0;
    }

    final needed = <String>{};
    for (var cx = minCx; cx <= maxCx; cx++) {
      for (var cy = minCy; cy <= maxCy; cy++) {
        needed.add('$cx,$cy');
      }
    }
    return needed;
  }

  Future<void> _loadChunk(String chunkId) async {
    final parts = chunkId.split(',');
    final cx = int.parse(parts[0]);
    final cy = int.parse(parts[1]);

    // Tile layers: copy the origin tiles shifted to this chunk position.
    final tilesByLayer = <TileLayerComponent, List<Tile>>{};
    for (final layer in layersComponent) {
      final base = _baseTilesByLayer[layer];
      if (base == null || base.isEmpty) {
        continue;
      }
      tilesByLayer[layer] = [
        for (final tile in base) _shiftTile(tile, cx, cy),
      ];
    }
    if (tilesByLayer.isNotEmpty) {
      tilesByLayer.forEach((layer, tiles) => layer.addTiles(tiles));
      _chunkTiles[chunkId] = tilesByLayer;
    }

    // Object layers: rebuild the object-layer components of the pattern and
    // shift them to this chunk.
    final built = await _builder.build(onlyObjects: true);
    final components = built.components ?? const <GameComponent>[];
    if (components.isNotEmpty) {
      final offset = Vector2(cx * _chunkWidthPx, cy * _chunkHeightPx);
      for (final component in components) {
        component.position += offset;
      }
      gameRef.addAll(components);
    }
    _chunkComponents[chunkId] = components;
    _loadedChunks.add(chunkId);
  }

  void _unloadChunk(String chunkId) {
    final tiles = _chunkTiles.remove(chunkId);
    tiles?.forEach((layer, copies) => layer.removeTiles(copies));

    final components = _chunkComponents.remove(chunkId);
    if (components != null) {
      for (final component in components) {
        if (component.isMounted) {
          component.removeFromParent();
        }
      }
    }
    _loadedChunks.remove(chunkId);
  }

  Tile _shiftTile(Tile tile, int chunkX, int chunkY) {
    return Tile(
      x: tile.x + chunkX * _chunkCols,
      y: tile.y + chunkY * _chunkRows,
      offsetX: tile.offsetX,
      offsetY: tile.offsetY,
      width: tile.width,
      height: tile.height,
      tileClass: tile.tileClass,
      properties: tile.properties,
      sprite: tile.sprite,
      color: tile.color,
      animation: tile.animation,
      collisions: tile.collisions,
      angle: tile.angle,
      opacity: tile.opacity,
      isFlipVertical: tile.isFlipVertical,
      isFlipHorizontal: tile.isFlipHorizontal,
    )..id = 'chunk_${chunkX}_${chunkY}_${tile.x}_${tile.y}';
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  ({int minCx, int maxCx, int minCy, int maxCy}) _windowFromIds(
    Set<String> ids,
  ) {
    var minCx = 0, maxCx = 0, minCy = 0, maxCy = 0;
    for (final id in ids) {
      final parts = id.split(',');
      final cx = int.parse(parts[0]);
      final cy = int.parse(parts[1]);
      minCx = math.min(minCx, cx);
      maxCx = math.max(maxCx, cx);
      minCy = math.min(minCy, cy);
      maxCy = math.max(maxCy, cy);
    }
    return (minCx: minCx, maxCx: maxCx, minCy: minCy, maxCy: maxCy);
  }

  bool _isChunkNearWindow(
    String chunkId,
    ({int minCx, int maxCx, int minCy, int maxCy}) window,
  ) {
    final parts = chunkId.split(',');
    final cx = int.parse(parts[0]);
    final cy = int.parse(parts[1]);
    return cx >= window.minCx - 1 &&
        cx <= window.maxCx + 1 &&
        cy >= window.minCy - 1 &&
        cy <= window.maxCy + 1;
  }

  void _refreshPriorityOffset() {
    var minCy = 0;
    for (final chunkId in _loadedChunks) {
      final cy = int.parse(chunkId.split(',')[1]);
      minCy = math.min(minCy, cy);
    }
    // When chunks above the origin are loaded the tiles start at negative
    // Y; shift component priorities by that amount so they keep rendering
    // above the map.
    _priorityOffsetY = minCy < 0 ? -minCy * _chunkHeightPx : 0;
  }

  Rect _collisionArea() {
    const big = 100000.0;
    final origin = super.getMapRect();
    switch (type) {
      case InfiniteWorldMapType.open:
        return Rect.fromLTRB(-big, -big, big, big);
      case InfiniteWorldMapType.vertical:
        return Rect.fromLTRB(
          origin.left - tileSize,
          -big,
          origin.right + tileSize,
          big,
        );
      case InfiniteWorldMapType.horizontal:
        return Rect.fromLTRB(
          -big,
          origin.top - tileSize,
          big,
          origin.bottom + tileSize,
        );
    }
  }

  @override
  Shape? getMoveAreaBounds(Rect visibleWorldRect) {
    const big = 100000.0;
    final origin = super.getMapRect();
    final halfW = visibleWorldRect.width / 2;
    final halfH = visibleWorldRect.height / 2;

    switch (type) {
      case InfiniteWorldMapType.open:
        return null;
      case InfiniteWorldMapType.vertical:
        final band = _finiteAxisBand(origin.left, origin.width, halfW);
        return Rectangle.fromRect(
          Rect.fromLTRB(band.$1, -big, band.$2, big),
        );
      case InfiniteWorldMapType.horizontal:
        final band = _finiteAxisBand(origin.top, origin.height, halfH);
        return Rectangle.fromRect(
          Rect.fromLTRB(-big, band.$1, big, band.$2),
        );
    }
  }

  /// Returns the (left/right or top/bottom) segment where the camera center
  /// may roam on a finite axis, in the same spirit of
  /// `Rect.deflatexy(halfVisible)`. When the axis is narrower than the
  /// visible area the segment collapses to the axis center.
  (double, double) _finiteAxisBand(double origin, double length, double half) {
    if (length <= half * 2) {
      final center = origin + length / 2;
      return (center, center);
    }
    return (origin + half, origin + length - half);
  }
}
