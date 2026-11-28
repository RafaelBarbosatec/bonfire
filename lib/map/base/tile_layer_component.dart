import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';
import 'package:bonfire/util/quadtree.dart' as tree;

class TileLayerComponent extends PositionComponent with HasPaint, WithShader {
  final int id;
  final String? name;
  final String? layerClass;
  final Map<String, dynamic>? properties;
  List<Tile> _tiles;
  bool _isVisible = true;
  double _tileSize = 0.0;

  Vector2? _lastScreenSize;

  double get tileSize => _tileSize;
  tree.QuadTree<Tile>? _quadTree;

  bool get visible => _isVisible;

  set visible(bool value) {
    _isVisible = value;
    refresh();
  }

  Set<String> _visibleSet = {};

  bool _pixelPerfect = true;

  /// Draws the layer without antialiasing and on whole device pixels.
  ///
  /// Tiles are separate `drawImageRect` calls that share an edge. With
  /// antialiasing on, a shared edge that falls on a fractional coordinate is
  /// drawn half-transparent by each tile; compositing two 50% edges leaves 25%
  /// of the background showing through, which reads as a dark line between
  /// tiles. It appears and disappears as the camera moves, because the
  /// fractional part changes with it.
  ///
  /// With antialiasing off the rasterizer gives every pixel to exactly one of
  /// the two quads, so there is no background left to show through. The layer
  /// translation is rounded to whole device pixels as well, which keeps each
  /// tile at a stable sub-pixel phase instead of crawling as the camera moves.
  ///
  /// Turn it off for layers that rely on smooth (non pixel-art) edges.
  bool get pixelPerfect => _pixelPerfect;

  set pixelPerfect(bool value) {
    if (_pixelPerfect == value) {
      return;
    }
    _pixelPerfect = value;
    paint.isAntiAlias = !value;
  }

  TileLayerComponent({
    required this.id,
    required List<Tile> tiles,
    super.position,
    bool visible = true,
    this.name,
    this.layerClass,
    double opacity = 1,
    this.properties,
    super.priority,
    bool pixelPerfect = true,
  })  : _tiles = tiles,
        _isVisible = visible {
    this.opacity = opacity;
    _pixelPerfect = pixelPerfect;
    paint.isAntiAlias = !pixelPerfect;
    _updateSizeAndPosition();
  }

  /// Translation, in the canvas' current coordinate space, that moves a layer
  /// onto whole device pixels.
  ///
  /// [transform] is a canvas transform matrix (`Canvas.getTransform`), which
  /// maps the current space to logical pixels, and [devicePixelRatio] turns
  /// those into device pixels. The result is `null` when the matrix is rotated
  /// or degenerate — "device pixel alignment" has no single axis there — and
  /// when the translation already lands on a pixel edge.
  static Vector2? devicePixelSnapOffset(
    List<double> transform,
    double devicePixelRatio,
  ) {
    if (devicePixelRatio <= 0) {
      return null;
    }
    // Column-major 4x4: [0] and [5] are the x/y scales, [1] and [4] the
    // rotation/skew terms, [12] and [13] the translation.
    final scaleX = transform[0];
    final scaleY = transform[5];
    if (scaleX == 0 || scaleY == 0) {
      return null;
    }
    if (transform[1] != 0 || transform[4] != 0) {
      return null;
    }
    final deviceX = transform[12] * devicePixelRatio;
    final deviceY = transform[13] * devicePixelRatio;
    final partialX = deviceX - deviceX.roundToDouble();
    final partialY = deviceY - deviceY.roundToDouble();
    if (partialX == 0 && partialY == 0) {
      return null;
    }
    return Vector2(
      -partialX / (scaleX * devicePixelRatio),
      -partialY / (scaleY * devicePixelRatio),
    );
  }

  @override
  void renderTree(Canvas canvas) {
    if (!_pixelPerfect) {
      super.renderTree(canvas);
      return;
    }
    final snap = devicePixelSnapOffset(
      canvas.getTransform(),
      _devicePixelRatio,
    );
    if (snap == null) {
      super.renderTree(canvas);
      return;
    }
    canvas.save();
    canvas.translate(snap.x, snap.y);
    super.renderTree(canvas);
    canvas.restore();
  }

  static double get _devicePixelRatio {
    final views = PlatformDispatcher.instance.views;
    return views.isEmpty ? 1.0 : views.first.devicePixelRatio;
  }

  void _updateSizeAndPosition() {
    if (_tiles.isNotEmpty) {
      _tileSize = _tiles.first.width;

      var w = _tiles.first.right;
      var h = _tiles.first.bottom;

      for (final tile in _tiles) {
        if (tile.right > w) {
          w = tile.right;
        }
        if (tile.bottom > h) {
          h = tile.bottom;
        }
      }
      size = Vector2(w, h);
    }
  }

  void initLayer(
    Vector2 gameSize,
    Vector2 screenSize, {
    bool infiniteMap = false,
  }) {
    if (gameSize.isZero()) {
      return;
    }
    _createQuadTree(
      gameSize,
      screenSize,
      infiniteMap: infiniteMap,
    );
  }

  void _createQuadTree(
    Vector2 mapSize,
    Vector2 screenSize, {
    bool force = false,
    bool infiniteMap = false,
  }) {
    if (_lastScreenSize == screenSize && !force) {
      return;
    }
    _lastScreenSize = screenSize.clone();
    var maxItems = 100;
    final minScreen = min(screenSize.x, screenSize.y);
    maxItems = ((minScreen / tileSize) / 2).ceil();
    if (infiniteMap) {
      // Infinite worlds add tiles at arbitrary (including very negative)
      // coordinates. Use huge bounds from the start so chunk additions never
      // need to rebuild the tree.
      const infiniteHalf = 1000000.0;
      _quadTree = tree.QuadTree(
        -infiniteHalf,
        -infiniteHalf,
        infiniteHalf * 2,
        infiniteHalf * 2,
        maxItems: maxItems,
      );
    } else {
      final treeSize = Vector2(
        mapSize.x / tileSize,
        mapSize.y / tileSize,
      );
      _quadTree = tree.QuadTree(
        0,
        0,
        treeSize.x,
        treeSize.y,
        maxItems: maxItems,
      );
    }

    for (final tile in _tiles) {
      _quadTree?.insert(
        tile,
        Point(tile.x, tile.y),
        id: tile.id,
      );
    }
  }

  void updateTiles(List<Tile> tiles) {
    _tiles = tiles;
    removeAll(children);
    _quadTree?.clear();
    _updateSizeAndPosition();

    for (final tile in _tiles) {
      _quadTree?.insert(
        tile,
        Point(tile.x, tile.y),
        id: tile.id,
      );
    }
    refresh();
  }

  void addTile(Tile tile) {
    _tiles.add(tile);
    _updateSizeAndPosition();
    _quadTree?.insert(
      tile,
      Point(tile.x, tile.y),
      id: tile.id,
    );
    refresh();
  }

  /// Adds many tiles at once (used by infinite maps when a new chunk loads).
  ///
  /// Grows the quad tree when a tile falls outside its current bounds, so
  /// chunks can be spawned at arbitrary (including negative) coordinates.
  void addTiles(List<Tile> tiles) {
    if (tiles.isEmpty) {
      return;
    }
    _tiles.addAll(tiles);
    final grew = _growQuadTreeToFit(tiles);
    if (!grew) {
      for (final tile in tiles) {
        _quadTree?.insert(
          tile,
          Point(tile.x, tile.y),
          id: tile.id,
        );
      }
    }
    // Differential update: only add the newly visible tiles and remove the
    // ones that are no longer visible — no full rebuild (cheap on chunk load).
    onMoveCamera(_lastRectCamera);
  }

  /// Removes many tiles at once (used by infinite maps when a chunk unloads).
  void removeTiles(List<Tile> tiles) {
    if (tiles.isEmpty) {
      return;
    }
    final ids = tiles.map((tile) => tile.id).toSet();
    _tiles.removeWhere((tile) => ids.contains(tile.id));
    for (final id in ids) {
      _quadTree?.removeById(id);
    }
    onMoveCamera(_lastRectCamera);
  }

  /// All tiles currently registered in this layer.
  List<Tile> get tiles => _tiles;

  bool _growQuadTreeToFit(List<Tile> newTiles) {
    final qt = _quadTree;
    if (qt == null) {
      return false;
    }
    final needsGrow = newTiles.any(
      (tile) => !qt.containsPoint(Point(tile.x, tile.y)),
    );
    if (!needsGrow) {
      return false;
    }

    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    for (final tile in _tiles) {
      minX = min(minX, tile.x);
      minY = min(minY, tile.y);
      maxX = max(maxX, tile.x);
      maxY = max(maxY, tile.y);
    }
    final pad = max(2.0, (max(maxX - minX, maxY - minY)) * 0.05);

    final maxItems = ((min(
                  _lastScreenSize?.x ?? 1,
                  _lastScreenSize?.y ?? 1,
                ) /
                _tileSize) /
            2)
        .ceil()
        .clamp(1, 1000);

    _quadTree = tree.QuadTree(
      minX - pad,
      minY - pad,
      (maxX - minX) + pad * 2,
      (maxY - minY) + pad * 2,
      maxItems: maxItems,
    );
    for (final tile in _tiles) {
      _quadTree?.insert(
        tile,
        Point(tile.x, tile.y),
        id: tile.id,
      );
    }
    return true;
  }

  void removeTile(String id) {
    try {
      _tiles.removeWhere((element) => element.id == id);
      _quadTree?.removeById(id);
      _updateSizeAndPosition();
      refresh();
    } catch (e) {
      // ignore: avoid_print
      print('Not found visible tile with $id id');
    }
  }

  void refresh() {
    _visibleSet.clear();
    removeAll(children);
    onMoveCamera(_lastRectCamera);
  }

  Rect _lastRectCamera = Rect.zero;

  Future<void> onMoveCamera(Rect rectCamera) {
    if (!_isVisible || _quadTree == null) {
      return Future.value();
    }
    _lastRectCamera = rectCamera;

    final visibleTiles = _quadTree!.query(
      rectCamera.getRectangleByTileSize(_tileSize),
    );

    final tilesToAdd = visibleTiles.where((element) {
      return !_visibleSet.contains(element.id);
    }).toList();

    _visibleSet = visibleTiles.map((e) => e.id).toSet();

    removeWhere((tile) => !_visibleSet.contains((tile as TileComponent).id));

    return addAll(_buildTiles(tilesToAdd));
  }

  Iterable<TileComponent> _buildTiles(Iterable<Tile> visibleTiles) {
    return visibleTiles.map((e) {
      return e.getTile();
    });
  }

  Future<void> loadAssets() async {
    // Large maps can contain thousands of tiles that all point at the same
    // spritesheet (a generated atlas, for instance). Loading the image once
    // per *unique path* instead of once per tile avoids thousands of redundant
    // cache lookups/awaits during map load.
    final paths = <String>{};
    for (final tile in _tiles) {
      final sprite = tile.sprite;
      if (sprite != null) paths.add(sprite.path);
      final animation = tile.animation;
      if (animation != null) {
        for (final frame in animation.frames) {
          paths.add(frame.path);
        }
      }
    }
    await Future.wait(paths.map(MapAssetsManager.loadImage));
  }

  @override
  Future onLoad() async {
    await loadAssets();
    return super.onLoad();
  }

  Iterable<TileComponent> getRendered() {
    return children.query<TileComponent>();
  }
}
