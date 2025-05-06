import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/base/layer.dart';
import 'package:bonfire/map/empty_map.dart';
import 'package:bonfire/map/util/layer_mapper.dart';
import 'package:bonfire/util/extensions/position_component_ext.dart';
import 'package:bonfire/util/quadtree.dart' as tree;

class WorldMap extends GameMap {
  Vector2 lastCameraWindow = Vector2.zero();
  double lastMinorZoom = 1.0;
  Vector2? lastSizeScreen;
  bool _buildingTiles = false;
  bool _needUpdateRenderedTiles = false;
  Vector2 _mapPosition = Vector2.zero();
  Vector2 _mapSize = Vector2.zero();

  tree.QuadTree<Tile>? quadTree;

  WorldMap(
    super.layers, {
    double tileSizeToUpdate = 0,
  }) : super(
          sizeToUpdate: tileSizeToUpdate,
        );

  factory WorldMap.empty({Vector2? size}) {
    return EmptyWorldMap(size: size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_buildingTiles && _checkNeedUpdateTiles()) {
      _buildingTiles = true;
      _searchTilesToRender();
    }
  }

  Future<void> _searchTilesToRender() async {
    final rectCamera = gameRef.camera.cameraRectWithSpacing;
    for (final layer in layersComponent) {
      await layer.onMoveCamera(rectCamera);
    }
    _buildingTiles = false;
    _needUpdateRenderedTiles = true;
  }

  List<TileComponent> _renderedTiles = [];

  @override
  Iterable<TileLayerComponent> get layersComponent =>
      children.whereType<TileLayerComponent>();

  @override
  List<TileComponent> getRenderedTiles() {
    if (_needUpdateRenderedTiles) {
      _needUpdateRenderedTiles = false;
      _renderedTiles = children.fold(
        <TileComponent>[],
        (previousValue, element) => previousValue
          ..addAll(
            (element as TileLayerComponent).getRendered(),
          ),
      );
    }
    return _renderedTiles;
  }

  @override
  void onGameResize(Vector2 size) {
    if (isLoaded) {
      _confMap(size);
    }
    super.onGameResize(size);
  }

  @override
  void refreshMap() {
    for (final element in layersComponent) {
      element.refresh();
    }
  }

  void _confMap(Vector2 sizeScreen, {bool calculateSize = false}) {
    lastSizeScreen = sizeScreen;
    if (calculateSize) {
      lastCameraWindow = Vector2.zero();
      lastMinorZoom = gameRef.camera.zoom;
      _calculatePositionAndSize();
      for (final layer in layersComponent) {
        layer.initLayer(size, sizeScreen);
      }
    }
    if (sizeToUpdate == 0) {
      sizeToUpdate = (tileSize * 4).ceilToDouble();
    }
    gameRef.camera.updateSpacingVisibleMap(sizeToUpdate * 1.5);
  }

  void _calculatePositionAndSize() {
    if (layersComponent.isNotEmpty) {
      tileSize = layersComponent.first.tileSize;
      var x = 0.0;
      var y = 0.0;

      var w = layersComponent.first.size.x;
      var h = layersComponent.first.size.y;

      for (final layer in layersComponent) {
        if (layer.left < x) {
          x = layer.left;
        }
        if (layer.top < y) {
          y = layer.top;
        }

        if (layer.right > w) {
          w = layer.right;
        }
        if (layer.bottom > h) {
          h = layer.bottom;
        }
      }
      _mapSize = Vector2(w - x, h - y);
      size = Vector2(w, h);
      _mapPosition = Vector2(x, y);

      gameRef.camera.updateBoundsAndZoomFit();
      gameRef.configCollisionDetection(
        Rect.fromLTWH(
          x - tileSize * 2,
          y - tileSize * 2,
          _mapSize.x.ceilToDouble() + tileSize * 4,
          _mapSize.y.ceilToDouble() + tileSize * 4,
        ),
      );
    }
  }

  @override
  Vector2 getMapSize() {
    return _mapSize;
  }

  @override
  Vector2 getMapPosition() {
    return _mapPosition;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await addAll(layers.map(LayerMapper.toLayerComponent));
    _confMap(gameRef.size, calculateSize: true);
  }

  bool _checkNeedUpdateTiles() {
    final window = _getCameraWindowUpdate();
    if (lastCameraWindow != window || lastMinorZoom != gameRef.camera.zoom) {
      updateLastCamera(window);
      return true;
    }
    return false;
  }

  void updateLastCamera(Vector2? camera) {
    lastCameraWindow = camera ?? _getCameraWindowUpdate();
    lastMinorZoom = gameRef.camera.zoom;
  }

  Vector2 _getCameraWindowUpdate() {
    final camera = gameRef.camera;
    return Vector2(
      (camera.position.x / (sizeToUpdate / camera.zoom)).floorToDouble(),
      (camera.position.y / (sizeToUpdate / camera.zoom)).floorToDouble(),
    );
  }

  @override
  Future<void> updateLayers(List<Layer> layers) async {
    this.layers = layers;
    removeAll(children);
    await addAll(layers.map(LayerMapper.toLayerComponent));
    _confMap(gameRef.size, calculateSize: true);
  }

  @override
  Future addLayer(Layer layer) async {
    layers.add(layer);
    add(LayerMapper.toLayerComponent(layer));
    _confMap(lastSizeScreen!, calculateSize: true);
    refreshMap();
  }

  @override
  void removeLayer(int id) {
    layers.removeWhere((l) => l.id == id);
    removeWhere(
      (component) => component is TileLayerComponent && component.id == id,
    );
    _confMap(lastSizeScreen!, calculateSize: true);
    refreshMap();
  }
}
