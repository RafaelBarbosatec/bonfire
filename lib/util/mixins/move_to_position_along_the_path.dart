import 'dart:math';
import 'dart:ui';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/mixins/movement.dart';
import 'package:flutter/material.dart';

mixin MoveToPositionAlongThePath on GameComponent {
  List<Offset> _currentPath = [];
  int _currentIndex = 0;
  double _speed = 0;
  Movement? _component;
  bool _showBarriers = false;
  bool _tileSizeIsSizeCollision = false;

  List<Offset> barriers = [];

  Color _pathLineColor = Colors.lightBlueAccent.withOpacity(0.5);
  double _pathLineStrokeWidth = 4;

  Paint _paintShowBarriers = Paint()..color = Colors.blue.withOpacity(0.5);

  void setupMoveToPositionAlongThePath({
    Color? pathLineColor,
    Color? barriersCalculatedColor,
    double pathLineStrokeWidth = 4,
    bool showBarriersCalculated = false,
    bool tileSizeIsSizeCollision = false,
  }) {
    _paintShowBarriers.color =
        barriersCalculatedColor ?? Colors.blue.withOpacity(0.5);
    this._showBarriers = showBarriersCalculated;
    _pathLineColor = pathLineColor ?? Colors.lightBlueAccent.withOpacity(0.5);
    _pathLineStrokeWidth = pathLineStrokeWidth;
    _tileSizeIsSizeCollision = tileSizeIsSizeCollision;
  }

  void moveToPositionAlongThePath(
    Vector2 position,
    double speed,
  ) {
    if (this is Movement) {
      _component = this as Movement;
      _currentIndex = 0;
      _calculatePath(position.toOffset());
      this._speed = speed;
    } else {
      print(
          'It was not possible to move components to the point. Implement "ComponentMovement" in its class');
    }
  }

  @override
  void update(double dt) {
    if (_currentPath.isNotEmpty) {
      _move(dt);
    }
    super.update(dt);
  }

  void render(Canvas c) {
    if (_showBarriers) {
      barriers.forEach((element) {
        c.drawRect(
          Rect.fromLTWH(
            element.dx * _tileSize,
            element.dy * _tileSize,
            _tileSize,
            _tileSize,
          ),
          _paintShowBarriers,
        );
      });
    }
    super.render(c);
  }

  void stopMoveAlongThePath() {
    _currentPath.clear();
    _currentIndex = 0;
    _component?.idle();
    gameRef.map.setLinePath(_currentPath, _pathLineColor, _pathLineStrokeWidth);
  }

  void _move(double dt) {
    double innerSpeed = _speed * dt;

    Vector2Rect componentPosition = position;
    if (this.isObjectCollision()) {
      componentPosition = (this as ObjectCollision).rectCollision;
    }
    double diffX = _currentPath[_currentIndex].dx - componentPosition.center.dx;
    double diffY = _currentPath[_currentIndex].dy - componentPosition.center.dy;
    double displacementX = diffX.abs() > innerSpeed ? _speed : diffX.abs() / dt;
    double displacementY = diffY.abs() > innerSpeed ? _speed : diffY.abs() / dt;

    if (diffX.abs() < 0.5 && diffY.abs() < 0.5) {
      if (_currentIndex < _currentPath.length - 1) {
        _currentIndex++;
      } else {
        stopMoveAlongThePath();
      }
    } else {
      if (diffX > 0 && diffX.abs() > 0.5) {
        _component?.moveRight(displacementX);
      }
      if (diffX < 0 && diffX.abs() > 0.5) {
        _component?.moveLeft(displacementX);
      }

      if (diffY > 0 && diffY.abs() > 0.5) {
        _component?.moveDown(displacementY);
      }
      if (diffY < 0 && diffY.abs() > 0.5) {
        _component?.moveUp(displacementY);
      }
    }
  }

  void _calculatePath(Offset finalPosition) {
    final player = this;

    final positionPlayer = player is ObjectCollision
        ? (player as ObjectCollision).rectCollision.center
        : player.position.center;

    Offset playerPosition = _getCenterPositionByTile(positionPlayer);

    Offset targetPosition = _getCenterPositionByTile(finalPosition);

    int columnsAdditional = ((gameRef.size.x / 2) / _tileSize).floor();
    int rowsAdditional = ((gameRef.size.y / 2) / _tileSize).floor();

    int rows = max(
          playerPosition.dy,
          targetPosition.dy,
        ).toInt() +
        rowsAdditional;

    int columns = max(
          playerPosition.dx,
          targetPosition.dx,
        ).toInt() +
        columnsAdditional;

    barriers.clear();

    gameRef.visibleCollisions().forEach((e) {
      if (e != this) {
        _addCollisionOffsetsPositionByTile(e.rectCollision);
      }
    });

    List<Offset> result = [];
    List<Offset> path = [];

    if (barriers.contains(targetPosition)) {
      stopMoveAlongThePath();
      return;
    }

    try {
      result = AStar(
        rows: rows + 1,
        columns: columns + 1,
        start: playerPosition,
        end: targetPosition,
        barriers: barriers,
      ).findThePath();

      if (result.isNotEmpty || _isNeighbor(playerPosition, targetPosition)) {
        path.add(playerPosition);
        path.addAll(result.reversed);
        path.add(targetPosition);
        path = path.map((e) {
          return Offset(e.dx * _tileSize, e.dy * _tileSize)
              .translate(_tileSize / 2, _tileSize / 2);
        }).toList();

        _currentPath = _resumePath(path);
        _currentIndex = 0;
      }
    } catch (e) {
      print('ERROR(AStar):$e');
    }
    gameRef.map.setLinePath(path, _pathLineColor, _pathLineStrokeWidth);
  }

  /// Get size of the grid used on algorithm to calculate path
  double get _tileSize {
    if (_tileSizeIsSizeCollision) {
      if (this.isObjectCollision()) {
        return max((this as ObjectCollision).rectCollision.width,
            (this as ObjectCollision).rectCollision.height);
      }
      return max(position.height, position.width);
    }
    if (gameRef.map.tiles.isNotEmpty) {
      return gameRef.map.tiles.first.width;
    }
    return 0.0;
  }

  bool get isMovingAlongThePath => _currentPath.isNotEmpty;

  Offset _getCenterPositionByTile(Offset center) {
    return Offset(
      (center.dx / _tileSize).floor().toDouble(),
      (center.dy / _tileSize).floor().toDouble(),
    );
  }

  /// creating an imaginary grid would calculate how many tile this object is occupying.
  void _addCollisionOffsetsPositionByTile(Vector2Rect rect) {
    final leftTop = Offset(
      (rect.left ~/ _tileSize * _tileSize),
      ((rect.top ~/ _tileSize) * _tileSize),
    );

    List<Rect> grid = [];
    int countColumns = (rect.width / _tileSize).ceil() + 1;
    int countRows = (rect.height / _tileSize).ceil() + 1;

    List.generate(countRows, (r) {
      List.generate(countColumns, (c) {
        grid.add(Rect.fromLTWH(
          leftTop.dx + (c * _tileSize),
          leftTop.dy + (r * _tileSize),
          _tileSize,
          _tileSize,
        ));
      });
    });

    List<Rect> listRect = grid.where((element) {
      return rect.rect.overlaps(element);
    }).toList();

    final result = listRect.map((e) {
      return Offset(
        (e.center.dx / _tileSize).floorToDouble(),
        (e.center.dy / _tileSize).floorToDouble(),
      );
    }).toList();

    result.forEach((element) {
      if (!barriers.contains(element)) {
        barriers.add(element);
      }
    });
  }

  /// Resume path
  /// Example:
  /// [(1,2),(1,3),(1,4),(1,5)] = [(1,2),(1,5)]
  List<Offset> _resumePath(List<Offset> path) {
    List<Offset> newPath = [];
    List<Offset> newPathStep1 = [];

    List<List<Offset>> listOffset = [];
    int indexList = -1;
    double currentY = 0;
    path.forEach((element) {
      if (element.dy == currentY) {
        listOffset[indexList].add(element);
      } else {
        currentY = element.dy;
        listOffset.add([element]);
        indexList++;
      }
    });

    listOffset.forEach((element) {
      if (element.length > 1) {
        newPathStep1.add(element.first);
        newPathStep1.add(element.last);
      } else {
        newPathStep1.add(element.first);
      }
    });

    indexList = -1;
    double currentX = 0;
    listOffset.clear();
    newPathStep1.forEach((element) {
      if (element.dx == currentX) {
        listOffset[indexList].add(element);
      } else {
        currentX = element.dx;
        listOffset.add([element]);
        indexList++;
      }
    });

    listOffset.forEach((element) {
      if (element.length > 1) {
        newPath.add(element.first);
        newPath.add(element.last);
      } else {
        newPath.add(element.first);
      }
    });

    return newPath;
  }

  bool _isNeighbor(Offset playerPosition, Offset targetPosition) {
    if ((playerPosition.dx - targetPosition.dx).abs() == 1 &&
        playerPosition.dy == targetPosition.dy) {
      return true;
    }
    if ((playerPosition.dy - targetPosition.dy).abs() == 1 &&
        playerPosition.dx == targetPosition.dx) {
      return true;
    }
    return false;
  }
}
