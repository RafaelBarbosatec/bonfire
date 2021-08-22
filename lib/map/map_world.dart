import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/map/tile/tile_model.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'map_assets_manager.dart';

class MapWorld extends MapGame {
  static const int SIZE_LOT_TILES_TO_PROCESS = 1000;
  Vector2 lastCamera = Vector2.zero();
  double lastZoom = -1;
  Vector2? lastSizeScreen;
  List<ObjectCollision> _tilesCollisions = List.empty();
  List<ObjectCollision> _tilesVisibleCollisions = List.empty();
  List<Iterable<TileModel>> _tilesLot = List.empty();
  List<Tile> _auxTiles = [];
  List<Tile> _tilesToRemove = [];
  bool processingTiles = false;

  List<Offset> _linePath = [];
  Paint _paintPath = Paint()
    ..color = Colors.lightBlueAccent.withOpacity(0.8)
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  int currentIndexProcess = -1;

  MapWorld(
    List<TileModel> tiles, {
    double tileSizeToUpdate = 0,
  }) : super(
          tiles,
          tileSizeToUpdate: tileSizeToUpdate,
        );

  @override
  void render(Canvas canvas) {
    for (var tile in children) {
      tile.render(canvas);
    }
    _drawPathLine(canvas);
  }

  @override
  void update(double t) {
    final camera = _getCameraTileUpdate();
    if (lastCamera != camera || lastZoom > gameRef.camera.config.zoom) {
      lastCamera = camera;
      if (lastZoom > gameRef.camera.config.zoom) {
        lastZoom = gameRef.camera.config.zoom;
      }
      if (currentIndexProcess == -1) {
        currentIndexProcess = 0;
      }
    }

    for (var tile in children) {
      tile.update(t);
      if (tile.shouldRemove) {
        _tilesToRemove.add(tile);
      }
    }

    _verifyRemoveTiles();

    if (currentIndexProcess != -1 && !processingTiles) {
      processingTiles = true;
      scheduleMicrotask(_updateTilesToRender);
    }
  }

  Future<void> _updateTilesToRender({bool processAllList = false}) async {
    Iterable<TileModel> visibleTiles =
        (processAllList ? tiles : _tilesLot[currentIndexProcess])
            .where((tile) => gameRef.camera.contains(tile.center));

    final newTiles = _buildTiles(visibleTiles);
    _auxTiles.addAll(newTiles);

    currentIndexProcess++;
    if (currentIndexProcess >= _tilesLot.length || processAllList) {
      children = _auxTiles.toList();

      _findVisibleCollisions();

      _auxTiles.clear();
      currentIndexProcess = -1;
    }
    processingTiles = false;
  }

  @override
  Iterable<Tile> getRendered() {
    return children;
  }

  @override
  Iterable<ObjectCollision> getCollisionsRendered() {
    return _tilesVisibleCollisions;
  }

  @override
  Iterable<ObjectCollision> getCollisions() {
    return _tilesCollisions;
  }

  @override
  void onGameResize(Vector2 size) {
    if (loaded) {
      _verifyMaxTopAndLeft(size);
    }
    super.onGameResize(size);
  }

  void _verifyMaxTopAndLeft(Vector2 size, {bool isUpdate = false}) {
    if (lastSizeScreen == size) return;
    lastSizeScreen = size.clone();

    if (isUpdate) {
      lastCamera = Vector2.zero();
      lastZoom = -1;
    }

    mapSize = getMapSize();
    mapStartPosition = getStartPosition();
    if (tiles.isNotEmpty && tileSizeToUpdate == 0) {
      tileSizeToUpdate = max(size.x, size.y) / 3;
      tileSizeToUpdate = tileSizeToUpdate.ceilToDouble();
    }
    gameRef.camera.updateSpacingVisibleMap(tileSizeToUpdate * 1.5);

    _getTileCollisions();

    _createTilesLot();
  }

  void _createTilesLot() {
    final countTiles = tiles.length;
    final countFramesToProcess =
        (countTiles / SIZE_LOT_TILES_TO_PROCESS).ceil();
    List<Iterable<TileModel>> aux = [];
    List.generate(countFramesToProcess, (index) {
      int startRange = SIZE_LOT_TILES_TO_PROCESS * index;
      int endRange = SIZE_LOT_TILES_TO_PROCESS * (index + 1);
      if (index == countFramesToProcess - 1) {
        endRange = countTiles;
      }
      aux.add(tiles.getRange(startRange, endRange).toList(growable: false));
    });
    _tilesLot = aux.toList(growable: false);
  }

  @override
  Future<void> updateTiles(List<TileModel> map) async {
    lastSizeScreen = null;
    this.tiles = map;
    _verifyMaxTopAndLeft(gameRef.size, isUpdate: true);
  }

  @override
  Size getMapSize() {
    double height = 0;
    double width = 0;

    this.tiles.forEach((tile) {
      if (tile.right > width) width = tile.right;
      if (tile.bottom > height) height = tile.bottom;
    });

    return Size(width, height);
  }

  Vector2 getStartPosition() {
    try {
      double x = this.tiles.first.left;
      double y = this.tiles.first.top;

      this.tiles.forEach((tile) {
        if (tile.left < x) x = tile.left;
        if (tile.top < y) y = tile.top;
      });

      return Vector2(x, y);
    } catch (e) {
      return Vector2.zero();
    }
  }

  @override
  void setLinePath(List<Offset> path, Color color, double strokeWidth) {
    _paintPath.color = color;
    _paintPath.strokeWidth = strokeWidth;
    _linePath = path;
    super.setLinePath(path, color, strokeWidth);
  }

  void _drawPathLine(Canvas canvas) {
    if (_linePath.isNotEmpty) {
      _paintPath.style = PaintingStyle.stroke;
      final path = Path()..moveTo(_linePath.first.dx, _linePath.first.dy);
      for (var i = 1; i < _linePath.length; i++) {
        path.lineTo(_linePath[i].dx, _linePath[i].dy);
      }
      canvas.drawPath(path, _paintPath);
    }
  }

  void _getTileCollisions() {
    List<ObjectCollision> aux = [];
    final list = tiles.where((element) {
      return element.collisions?.isNotEmpty == true;
    });

    for (var element in list) {
      final o = element.getTile(gameRef);
      aux.add(o as ObjectCollision);
    }
    _tilesCollisions = aux;
  }

  List<Tile> _buildTiles(Iterable<TileModel> visibleTiles) {
    List<Tile> aux = [];
    for (var element in visibleTiles) {
      final tile = element.getTile(gameRef);
      aux.add(tile);
    }
    return aux;
  }

  @override
  Future<void>? onLoad() async {
    await Future.forEach<TileModel>(tiles, (element) async {
      if (element.sprite != null) {
        await MapAssetsManager.loadImage(element.sprite!.path);
      }
      if (element.animation != null) {
        for (var frame in element.animation!.frames) {
          await MapAssetsManager.loadImage(frame.path);
        }
      }
    });
    _verifyMaxTopAndLeft(gameRef.size);
    await _updateTilesToRender(processAllList: true);
    return super.onLoad();
  }

  Vector2 _getCameraTileUpdate() {
    return Vector2(
      (gameRef.camera.position.dx / tileSizeToUpdate).floorToDouble(),
      (gameRef.camera.position.dy / tileSizeToUpdate).floorToDouble(),
    );
  }

  void _verifyRemoveTiles() {
    if (_tilesToRemove.isNotEmpty) {
      _tilesToRemove.forEach((tile) {
        children.remove(tile);
        tiles.removeWhere((element) => element.id == tile.id);
        if (tile is ObjectCollision) {
          _tilesCollisions.removeWhere((element) {
            return (element as Tile).id == tile.id;
          });
          _tilesVisibleCollisions.removeWhere((element) {
            return (element as Tile).id == tile.id;
          });
        }
      });
      _createTilesLot();
    }
  }

  @override
  Future addTile(TileModel tileModel) async {
    final tile = tileModel.getTile(gameRef);
    await tile.onLoad();
    tiles.add(tileModel);
    children.add(tile);

    if (tile is ObjectCollision) {
      _tilesCollisions.add(tile as ObjectCollision);
      _findVisibleCollisions();
    }
    _createTilesLot();
  }

  @override
  void removeTile(String id) {
    try {
      children.firstWhere((element) => element.id == id).remove();
    } catch (e) {
      print('Not found visible tile with $id id');
    }
  }

  void _findVisibleCollisions() {
    _tilesVisibleCollisions = children
        .where((element) {
          return element is ObjectCollision;
        })
        .toList()
        .cast();
  }
}
