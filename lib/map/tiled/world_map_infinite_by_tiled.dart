import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';

enum InfiniteWorldMapType { OPEN, VERTICAL, HORIZONTAL }

class WorldMapInfiniteByTiled extends WorldMap {
  bool _isExecutingLoadChunk = false;
  bool _isExecutingDistantChunk = false;

  final Map<int, List<Tile>> initialTilesPerLayerMap = {};
  final Set<String> loadedChunkIds = {};
  final Map<String, Set<String>> loadedChunkTiles = {};
  final Map<String, List<GameComponent>> loadedChunkComponents = {};

  late TiledWorldBuilder _builder;
  final List<GameComponent> _components = [];
  late final double _chunkSizeX;
  late final double _chunkSizeY;
  final Map<String, ObjectBuilder>? objectsBuilder;
  final InfiniteWorldMapType type;
  final double cameraMargin;

  WorldMapInfiniteByTiled(
    WorldMapReader<TiledMap> reader, {
    Vector2? forceTileSize,
    ValueChanged<Object>? onError,
    double sizeToUpdate = 0,
    this.objectsBuilder,
    this.type = InfiniteWorldMapType.OPEN,
    this.cameraMargin = 100,
  }) : super(const [], infinite: true) {
    this.sizeToUpdate = sizeToUpdate;
    _builder = TiledWorldBuilder(
      reader,
      forceTileSize: forceTileSize,
      onError: onError,
      sizeToUpdate: sizeToUpdate,
      objectsBuilder: objectsBuilder,
    );
  }

  @override
  Future<void> onLoad() async {
    final map = await _builder.build();
    layers = map.map.layers;
    if (map.components != null) {
      _components.addAll(map.components!);
    }
    gameRef.addAll(_components);
    await super.onLoad();

    _chunkSizeX = size.x / tileSize;
    _chunkSizeY = size.y / tileSize;
     
    _loadInitialTilesMap();
  }

  void _loadInitialTilesMap() {
    loadedChunkIds.add(_getChunkId(0, 0));
    for (var layerComponent in layersComponent) {
      initialTilesPerLayerMap[layerComponent.id] = List.from(layerComponent.getTiles());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _loadChunks();
  }

  Future<void> _loadChunks() async {
    if (_isExecutingLoadChunk) return;

    _isExecutingLoadChunk = true;
    _removeDistantChunks();
    
    final cameraBounds = gameRef.camera.visibleWorldRect;
    final chunkSizeWidth = _chunkSizeX * tileSize;
    final chunkSizeHeight = _chunkSizeY * tileSize;

    int minChunkX = ((cameraBounds.left - cameraMargin) / chunkSizeWidth).floor();
    int maxChunkX = ((cameraBounds.right + cameraMargin) / chunkSizeWidth).floor();
    int minChunkY = ((cameraBounds.top - cameraMargin) / chunkSizeHeight).floor();
    int maxChunkY = ((cameraBounds.bottom + cameraMargin) / chunkSizeHeight).floor();

    if (type == InfiniteWorldMapType.VERTICAL) {
      minChunkX = maxChunkX = 0;
    } else if (type == InfiniteWorldMapType.HORIZONTAL) {
      minChunkY = maxChunkY = 0;
    }

    for (int chunkX = minChunkX; chunkX <= maxChunkX; chunkX++) {
      for (int chunkY = minChunkY; chunkY <= maxChunkY; chunkY++) {
        final chunkId = _getChunkId(chunkX, chunkY);
        if (loadedChunkIds.contains(chunkId)) continue;

        _buildLayersChunk(chunkId, chunkX, chunkY);
        await _buildComponentsChunk(chunkId, chunkX, chunkY);

        loadedChunkIds.add(chunkId);
      }
    }

    _isExecutingLoadChunk = false;
  }

  void _buildLayersChunk(String chunkId, int chunkX, int chunkY) {
    for (var layerComponent in layersComponent) {
      final String layerChunkId = _getLayerChunkId(layerComponent.id, chunkId);
      if (loadedChunkTiles.containsKey(layerChunkId)) continue;

      final List<Tile> newTiles = initialTilesPerLayerMap[layerComponent.id]!
          .map((tile) => _getTileCopy(tile, tile.x + chunkX * _chunkSizeX, tile.y + chunkY * _chunkSizeY))
          .toList();

      if (newTiles.isNotEmpty) {
        loadedChunkTiles[layerChunkId] = newTiles.map((tile) => tile.id).toSet();
        layerComponent.updateTiles([...layerComponent.getTiles(), ...newTiles]);
      }
    }
  }

  Future<void> _buildComponentsChunk(String chunkId, int chunkX, int chunkY) async {
    final map = await _builder.build(onlyObjects: true);
    final componentsToAdd = map.components?.where((component) => !_components.contains(component)).toList() ?? [];

    if (componentsToAdd.isNotEmpty) {
      final offset = Vector2(chunkX * _chunkSizeX * tileSize, chunkY * _chunkSizeY * tileSize);
      for (var component in componentsToAdd) {
        component.position += offset;
      }

      gameRef.addAll(componentsToAdd);
      _components.addAll(componentsToAdd);
    }

    loadedChunkComponents[chunkId] = componentsToAdd;
  }

  Future<void> _removeDistantChunks({int chunkRange = 1}) async {
    if (_isExecutingDistantChunk) return;
    _isExecutingDistantChunk = true;

    final currentChunk = getCurrentChunk(gameRef.camera.visibleWorldRect.centerVector2);
    final List<String> chunksToRemove = [];

    for (var chunkId in loadedChunkIds) {
      final chunkCoordinates = chunkId.split(',').map(int.parse).toList();
      final chunkX = chunkCoordinates[0];
      final chunkY = chunkCoordinates[1];

      if ((chunkX - currentChunk.x).abs() > chunkRange || (chunkY - currentChunk.y).abs() > chunkRange) {
        chunksToRemove.add(chunkId);
      }
    }

    for (var chunkId in chunksToRemove) {
      _removeComponentsChunk(chunkId);
      loadedChunkIds.remove(chunkId);
    }

    _isExecutingDistantChunk = false;
  }

  void _removeComponentsChunk(String chunkId) {
    if (loadedChunkComponents.containsKey(chunkId)) {
      for (var component in loadedChunkComponents[chunkId]!) {
        component.removeFromParent();
        _components.remove(component);
      }
      loadedChunkComponents.remove(chunkId);
    }
  }

  String _getChunkId(int chunkX, int chunkY) {
    return '$chunkX,$chunkY';
  }

  String _getLayerChunkId(int layer, String chunkId) {
    return '$layer-$chunkId';
  }

  Tile _getTileCopy(Tile tile, double positionX, double positionY) {
    return Tile(
      x: positionX,
      y: positionY,
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
    );
  }

  Vector2 getCurrentChunk(Vector2 position) {
    final int chunkX = (position.x / (_chunkSizeX * tileSize)).floor();
    final int chunkY = (position.y / (_chunkSizeY * tileSize)).floor();
    return Vector2(chunkX.toDouble(), chunkY.toDouble());
  }
}