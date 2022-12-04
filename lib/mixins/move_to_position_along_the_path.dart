// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'dart:ui';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/line_path_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Mixin responsible for find path using `a_star_algorithm` and moving the component through the path
mixin MoveToPositionAlongThePath on Movement {
  static const REDUCTION_TO_AVOID_ROUNDING_PROBLEMS = 4;

  List<Offset> _currentPath = [];
  int _currentIndex = 0;
  bool _showBarriers = false;
  bool _gridSizeIsCollisionSize = false;
  double _factorInflateFindArea = 2;
  VoidCallback? _onFinish;

  final List<Offset> _barriers = [];
  List ignoreCollisions = [];

  LinePathComponent? _linePathComponent;
  Color _pathLineColor = const Color(0xFF40C4FF).withOpacity(0.5);
  double _pathLineStrokeWidth = 4;
  final Paint _paintShowBarriers = Paint()
    ..color = const Color(0xFF2196F3).withOpacity(0.5);

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
    double factorInflateFindArea = 2,
  }) {
    _factorInflateFindArea = factorInflateFindArea;
    _paintShowBarriers.color =
        barriersCalculatedColor ?? const Color(0xFF2196F3).withOpacity(0.5);
    _showBarriers = showBarriersCalculated;

    _pathLineColor = pathLineColor ?? _pathLineColor;
    _pathLineStrokeWidth = pathLineStrokeWidth;
    _pathLineColor = pathLineColor ?? const Color(0xFF40C4FF).withOpacity(0.5);
    _gridSizeIsCollisionSize = gridSizeIsCollisionSize;
  }

  Future<List<Offset>> moveToPositionAlongThePath(
    Vector2 position, {
    List? ignoreCollisions,
    VoidCallback? onFinish,
  }) {
    if (!hasGameRef) {
      return Future.value([]);
    }

    _onFinish = onFinish;
    this.ignoreCollisions.clear();
    this.ignoreCollisions.add(this);
    if (ignoreCollisions != null) {
      this.ignoreCollisions.addAll(ignoreCollisions);
    }

    _currentIndex = 0;
    _removeLinePathComponent();

    return Future.microtask(() {
      return _calculatePath(position);
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_currentPath.isNotEmpty) {
      _move(dt);
    }
  }

  @override
  void renderBeforeTransformation(Canvas canvas) {
    _drawBarrries(canvas);
    super.renderBeforeTransformation(canvas);
  }

  void stopMoveAlongThePath() {
    _currentPath.clear();
    _barriers.clear();
    _currentIndex = 0;
    _removeLinePathComponent();
    idle();
    _onFinish?.call();
    _onFinish = null;
  }

  void _move(double dt) {
    double innerSpeed = speed * dt;
    Vector2 center = this.center;
    if (isObjectCollision()) {
      center = (this as ObjectCollision).rectCollision.center.toVector2();
    }
    double diffX = _currentPath[_currentIndex].dx - center.x;
    double diffY = _currentPath[_currentIndex].dy - center.y;
    double displacementX = diffX.abs() > innerSpeed ? speed : diffX.abs() / dt;
    double displacementY = diffY.abs() > innerSpeed ? speed : diffY.abs() / dt;

    if (diffX.abs() < 0.01 && diffY.abs() < 0.01) {
      _goToNextPosition();
    } else {
      bool onMove = false;
      if (diffX.abs() > 0.01 && diffY.abs() > 0.01) {
        if (diffX > 0 && diffY > 0) {
          onMove = moveDownRight(
            displacementX,
            displacementY,
          );
        } else if (diffX < 0 && diffY > 0) {
          onMove = moveDownLeft(
            displacementX,
            displacementY,
          );
        } else if (diffX > 0 && diffY < 0) {
          onMove = moveUpRight(
            displacementX,
            displacementY,
          );
        } else if (diffX < 0 && diffY < 0) {
          onMove = moveUpLeft(
            displacementX,
            displacementY,
          );
        }
      } else if (diffX.abs() > 0.01) {
        if (diffX > 0) {
          onMove = moveRight(displacementX);
        } else if (diffX < 0) {
          onMove = moveLeft(displacementX);
        }
      } else if (diffY.abs() > 0.01) {
        if (diffY > 0) {
          onMove = moveDown(displacementY);
        } else if (diffY < 0) {
          onMove = moveUp(displacementY);
        }
      }

      if (!onMove) {
        _goToNextPosition();
      }
    }
  }

  List<Offset> _calculatePath(Vector2 finalPosition) {
    final player = this;

    final positionPlayer = player is ObjectCollision
        ? (player as ObjectCollision).rectCollision.center.toVector2()
        : player.center;

    Offset playerPosition = _getCenterPositionByTile(positionPlayer);

    Offset targetPosition = _getCenterPositionByTile(finalPosition);

    double inflate = _tileSize * _factorInflateFindArea;

    double maxY = max(
      playerPosition.dy,
      targetPosition.dy,
    );

    double maxX = max(
      playerPosition.dx,
      targetPosition.dx,
    );

    int rows = maxY.toInt() + inflate.toInt();

    int columns = maxX.toInt() + inflate.toInt();

    _barriers.clear();

    Rect area =
        Rect.fromPoints(positionPlayer.toOffset(), finalPosition.toOffset());

    double left = area.left;
    double right = area.right;
    double top = area.top;
    double bottom = area.bottom;
    double size = max(area.width, area.height);
    if (positionPlayer.x < finalPosition.x) {
      left -= size;
    } else if (positionPlayer.x > finalPosition.x) {
      right += size;
    }

    if (positionPlayer.y < finalPosition.y) {
      top -= size;
    } else if (positionPlayer.y > finalPosition.y) {
      bottom += size;
    }

    area = Rect.fromLTRB(left, top, right, bottom).inflate(inflate);

    for (final e in gameRef.collisions()) {
      if (!ignoreCollisions.contains(e) && area.overlaps(e.rectCollision)) {
        _addCollisionOffsetsPositionByTile(e.rectCollision);
      }
    }

    Iterable<Offset> result = [];

    if (_barriers.contains(targetPosition)) {
      stopMoveAlongThePath();
      return [];
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
        result = AStar.resumePath(result);
        _currentPath = result.map((e) {
          return Offset(e.dx * _tileSize, e.dy * _tileSize)
              .translate(_tileSize / 2, _tileSize / 2);
        }).toList();

        _currentIndex = 0;
      }
    } catch (e) {
      // ignore: avoid_print
      print('ERROR(AStar):$e');
    }
    gameRef.add(
      _linePathComponent = LinePathComponent(
        _currentPath,
        _pathLineColor,
        _pathLineStrokeWidth,
      ),
    );
    return _currentPath;
  }

  /// Get size of the grid used on algorithm to calculate path
  double get _tileSize {
    double tileSize = 0.0;
    if (gameRef.map.tiles.isNotEmpty) {
      tileSize = gameRef.map.tiles.first.width;
    }
    if (_gridSizeIsCollisionSize) {
      if (isObjectCollision()) {
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
      (center.x / _tileSize).floorToDouble(),
      (center.y / _tileSize).floorToDouble(),
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

    for (var element in result) {
      if (!_barriers.contains(element)) {
        _barriers.add(element);
      }
    }
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

  void _drawBarrries(Canvas canvas) {
    if (_showBarriers) {
      for (var element in _barriers) {
        canvas.drawRect(
          Rect.fromLTWH(
            element.dx * _tileSize,
            element.dy * _tileSize,
            _tileSize,
            _tileSize,
          ),
          _paintShowBarriers,
        );
      }
    }
  }

  @override
  void onRemove() {
    _removeLinePathComponent();
    super.onRemove();
  }

  void _removeLinePathComponent() {
    _linePathComponent?.removeFromParent();
    _linePathComponent = null;
  }
}
