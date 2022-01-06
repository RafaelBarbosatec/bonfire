import 'dart:math';
import 'dart:ui';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

enum TypeResumeDirection {
  axisX,
  axisY,
  topLeft,
  bottomLeft,
  topRight,
  bottomRight,
}

/// Mixin responsible for find path using `a_star_algorithm` and moving the component through the path
mixin MoveToPositionAlongThePath on Movement {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;
  static const REDUCTION_TO_AVOID_ROUNDING_PROBLEMS = 4;

  List<Offset> _currentPath = [];
  int _currentIndex = 0;
  bool _showBarriers = false;
  bool _gridSizeIsCollisionSize = false;

  List<Offset> _barriers = [];
  List ignoreCollisions = [];

  Color _pathLineColor = Color(0xFF40C4FF).withOpacity(0.5);
  double _pathLineStrokeWidth = 4;

  Paint _paintShowBarriers = Paint()
    ..color = Color(0xFF2196F3).withOpacity(0.5);

  void setupMoveToPositionAlongThePath({
    /// Use to set line path color
    Color? pathLineColor,
    Color? barriersCalculatedColor,

    /// Use to set line path width
    double pathLineStrokeWidth = 4,

    /// Use to debug and show area collision calculated
    bool showBarriersCalculated = false,

    /// If `false` the algorithm use map tile size with base of the grid. if true this use collision size of the component.
    bool gridSizeIsCollisionSize = false,
  }) {
    _paintShowBarriers.color =
        barriersCalculatedColor ?? Color(0xFF2196F3).withOpacity(0.5);
    this._showBarriers = showBarriersCalculated;
    _pathLineColor = pathLineColor ?? Color(0xFF40C4FF).withOpacity(0.5);
    _pathLineStrokeWidth = pathLineStrokeWidth;
    _gridSizeIsCollisionSize = gridSizeIsCollisionSize;
  }

  void moveToPositionAlongThePath(
    Vector2 position, {
    List? ignoreCollisions,
  }) {
    this.ignoreCollisions.clear();
    this.ignoreCollisions.add(this);
    if (ignoreCollisions != null) {
      this.ignoreCollisions.addAll(ignoreCollisions);
    }

    _currentIndex = 0;
    _calculatePath(position);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_currentPath.isNotEmpty) {
      _move(dt);
    }
  }

  void render(Canvas c) {
    if (_showBarriers) {
      _barriers.forEach((element) {
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
    this.idle();
    gameRef.map.setLinePath(_currentPath, _pathLineColor, _pathLineStrokeWidth);
  }

  void _move(double dt) {
    double innerSpeed = speed * dt;
    Vector2 center = this.center;
    if (this.isObjectCollision()) {
      center = (this as ObjectCollision).rectCollision.center.toVector2();
    }
    double diffX = _currentPath[_currentIndex].dx - center.x;
    double diffY = _currentPath[_currentIndex].dy - center.y;
    double displacementX = diffX.abs() > innerSpeed ? speed : diffX.abs() / dt;
    double displacementY = diffY.abs() > innerSpeed ? speed : diffY.abs() / dt;

    if (diffX.abs() < 0.01 && diffY.abs() < 0.01) {
      _goToNextPosition();
    } else {
      if (diffX.abs() > 0.01 && diffY.abs() > 0.01) {
        final displacementXDiagonal = displacementX * REDUCTION_SPEED_DIAGONAL;
        final displacementYDiagonal = displacementY * REDUCTION_SPEED_DIAGONAL;
        if (diffX > 0 && diffY > 0) {
          this.moveDownRight(
            displacementXDiagonal,
            displacementYDiagonal,
            onCollision: _goToNextPosition,
          );
        } else if (diffX < 0 && diffY > 0) {
          this.moveDownLeft(
            displacementXDiagonal,
            displacementYDiagonal,
            onCollision: _goToNextPosition,
          );
        } else if (diffX > 0 && diffY < 0) {
          this.moveUpRight(
            displacementXDiagonal,
            displacementYDiagonal,
            onCollision: _goToNextPosition,
          );
        } else if (diffX < 0 && diffY < 0) {
          this.moveUpLeft(
            displacementXDiagonal,
            displacementYDiagonal,
            onCollision: _goToNextPosition,
          );
        }
      } else if (diffX.abs() > 0.01) {
        if (diffX > 0) {
          this.moveRight(displacementX, onCollision: _goToNextPosition);
        } else if (diffX < 0) {
          this.moveLeft(displacementX, onCollision: _goToNextPosition);
        }
      } else if (diffY.abs() > 0.01) {
        if (diffY > 0) {
          this.moveDown(displacementY, onCollision: _goToNextPosition);
        } else if (diffY < 0) {
          this.moveUp(displacementY, onCollision: _goToNextPosition);
        }
      } else {
        _goToNextPosition();
      }
    }
  }

  void _calculatePath(Vector2 finalPosition) {
    final player = this;

    final positionPlayer = player is ObjectCollision
        ? (player as ObjectCollision).rectCollision.center.toVector2()
        : player.center;

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

    _barriers.clear();

    gameRef.visibleCollisions().forEach((e) {
      if (!ignoreCollisions.contains(e)) {
        _addCollisionOffsetsPositionByTile(e.rectCollision);
      }
    });

    List<Offset> result = [];
    List<Offset> path = [];

    if (_barriers.contains(targetPosition)) {
      stopMoveAlongThePath();
      return;
    }

    try {
      result = AStar(
        rows: rows + 1,
        columns: columns + 1,
        start: playerPosition,
        end: targetPosition,
        barriers: _barriers,
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

        final pointsOutOfTheCamera = _currentPath.where((element) {
          return !gameRef.camera.cameraRect.contains(element);
        });

        if (pointsOutOfTheCamera.isNotEmpty) {
          stopMoveAlongThePath();
          return;
        }
      }
    } catch (e) {
      print('ERROR(AStar):$e');
    }
    gameRef.map.setLinePath(path, _pathLineColor, _pathLineStrokeWidth);
  }

  /// Get size of the grid used on algorithm to calculate path
  double get _tileSize {
    double tileSize = 0.0;
    if (gameRef.map.tiles.isNotEmpty) {
      tileSize = gameRef.map.tiles.first.width;
    }
    if (_gridSizeIsCollisionSize) {
      if (this.isObjectCollision()) {
        return max(
          (this as ObjectCollision).rectCollision.width,
          (this as ObjectCollision).rectCollision.height,
        );
      }
      return max(height, width) + REDUCTION_TO_AVOID_ROUNDING_PROBLEMS;
    }
    return tileSize;
  }

  bool get isMovingAlongThePath => _currentPath.isNotEmpty;

  Offset _getCenterPositionByTile(Vector2 center) {
    return Offset(
      (center.x / _tileSize).floor().toDouble(),
      (center.y / _tileSize).floor().toDouble(),
    );
  }

  /// creating an imaginary grid would calculate how many tile this object is occupying.
  void _addCollisionOffsetsPositionByTile(Rect rect) {
    final leftTop = Offset(
      ((rect.left / _tileSize).floor() * _tileSize),
      ((rect.top / _tileSize).floor() * _tileSize),
    );

    List<Rect> grid = [];
    int countColumns = (rect.width / _tileSize).ceil() + 1;
    int countRows = (rect.height / _tileSize).ceil() + 1;

    List.generate(countRows, (r) {
      List.generate(countColumns, (c) {
        grid.add(Rect.fromLTWH(
          leftTop.dx +
              (c * _tileSize) +
              REDUCTION_TO_AVOID_ROUNDING_PROBLEMS / 2,
          leftTop.dy +
              (r * _tileSize) +
              REDUCTION_TO_AVOID_ROUNDING_PROBLEMS / 2,
          _tileSize - REDUCTION_TO_AVOID_ROUNDING_PROBLEMS,
          _tileSize - REDUCTION_TO_AVOID_ROUNDING_PROBLEMS,
        ));
      });
    });

    List<Rect> listRect = grid.where((element) {
      return rect.overlaps(element);
    }).toList();

    final result = listRect.map((e) {
      return Offset(
        (e.center.dx / _tileSize).floorToDouble(),
        (e.center.dy / _tileSize).floorToDouble(),
      );
    }).toList();

    result.forEach((element) {
      if (!_barriers.contains(element)) {
        _barriers.add(element);
      }
    });
  }

  /// Resume path
  /// Example:
  /// [(1,2),(1,3),(1,4),(1,5)] = [(1,2),(1,5)]
  List<Offset> _resumePath(List<Offset> path) {
    List<Offset> newPath = _resumeDirection(path, TypeResumeDirection.axisX);
    newPath = _resumeDirection(newPath, TypeResumeDirection.axisY);
    newPath = _resumeDirection(newPath, TypeResumeDirection.bottomLeft);
    newPath = _resumeDirection(newPath, TypeResumeDirection.bottomRight);
    newPath = _resumeDirection(newPath, TypeResumeDirection.topLeft);
    newPath = _resumeDirection(newPath, TypeResumeDirection.topRight);
    return newPath;
  }

  List<Offset> _resumeDirection(List<Offset> path, TypeResumeDirection type) {
    List<Offset> newPath = [];
    List<List<Offset>> listOffset = [];
    int indexList = -1;
    double currentX = 0;
    double currentY = 0;

    path.forEach((element) {
      final dxDiagonal = element.dx.floor();
      final dyDiagonal = element.dy.floor();

      switch (type) {
        case TypeResumeDirection.axisX:
          if (element.dx == currentX) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.axisY:
          if (element.dy == currentY) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.topLeft:
          final nextDxDiagonal = (currentX - _tileSize).floor();
          final nextDyDiagonal = (currentY - _tileSize).floor();
          if (dxDiagonal == nextDxDiagonal && dyDiagonal == nextDyDiagonal) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.bottomLeft:
          final nextDxDiagonal = (currentX - _tileSize).floor();
          final nextDyDiagonal = (currentY + _tileSize).floor();
          if (dxDiagonal == nextDxDiagonal && dyDiagonal == nextDyDiagonal) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.topRight:
          final nextDxDiagonal = (currentX + _tileSize).floor();
          final nextDyDiagonal = (currentY - _tileSize).floor();
          if (dxDiagonal == nextDxDiagonal && dyDiagonal == nextDyDiagonal) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.bottomRight:
          final nextDxDiagonal = (currentX + _tileSize).floor();
          final nextDyDiagonal = (currentY + _tileSize).floor();
          if (dxDiagonal == nextDxDiagonal && dyDiagonal == nextDyDiagonal) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
      }

      currentX = element.dx;
      currentY = element.dy;
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
    if ((playerPosition.dx - targetPosition.dx).abs() == 1) {
      return true;
    }
    if ((playerPosition.dy - targetPosition.dy).abs() == 1) {
      return true;
    }
    return false;
  }

  void _goToNextPosition() {
    if (_currentIndex < _currentPath.length - 1) {
      _currentIndex++;
    } else {
      stopMoveAlongThePath();
    }
  }
}
