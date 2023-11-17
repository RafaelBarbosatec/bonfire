// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'dart:ui';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/line_path_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Mixin responsible for find path using `a_star_algorithm` and moving the component through the path
mixin PathFinding on Movement {
  static const REDUCTION_TO_AVOID_ROUNDING_PROBLEMS = 4;

  List<Vector2> _currentPath = [];
  int _currentIndex = 0;
  bool _linePathEnabled = true;
  bool _showBarriers = false;
  bool _gridSizeIsCollisionSize = false;
  bool _useOnlyVisibleBarriers = true;
  double _factorInflateFindArea = 2;
  VoidCallback? _onFinish;

  final List<Point<int>> _barriers = [];
  final List _ignoreCollisions = [];

  LinePathComponent? _linePathComponent;
  Color _pathLineColor = const Color(0xFF40C4FF).withOpacity(0.5);
  double _pathLineStrokeWidth = 4;
  final Paint _paintShowBarriers = Paint()
    ..color = const Color(0xFF2196F3).withOpacity(0.5);

  void setupPathFinding({
    bool? linePathEnabled,

    /// Use to set line path color
    Color? pathLineColor,
    Color? barriersCalculatedColor,

    /// Use to set line path width
    double pathLineStrokeWidth = 4,

    /// Use to debug and show area collision calculated
    bool showBarriersCalculated = false,
    bool useOnlyVisibleBarriers = true,

    /// If `false` the algorithm use map tile size with base of the grid. if true this use collision size of the component.
    bool gridSizeIsCollisionSize = false,
    double factorInflateFindArea = 2,
  }) {
    _linePathEnabled = linePathEnabled ?? _linePathEnabled;
    _useOnlyVisibleBarriers = useOnlyVisibleBarriers;
    _factorInflateFindArea = factorInflateFindArea;
    _paintShowBarriers.color =
        barriersCalculatedColor ?? const Color(0xFF2196F3).withOpacity(0.5);
    _showBarriers = showBarriersCalculated;

    _pathLineColor = pathLineColor ?? _pathLineColor;
    _pathLineStrokeWidth = pathLineStrokeWidth;
    _pathLineColor = pathLineColor ?? const Color(0xFF40C4FF).withOpacity(0.5);
    _gridSizeIsCollisionSize = gridSizeIsCollisionSize;
  }

  Future<List<Vector2>> moveToPositionWithPathFinding(
    Vector2 position, {
    List? ignoreCollisions,
    VoidCallback? onFinish,
  }) async {
    if (!hasGameRef) {
      return Future.value([]);
    }

    _onFinish = onFinish;
    _currentIndex = 0;
    _removeLinePathComponent();

    _currentPath = await Future.microtask(
      () => getPathToPosition(
        position,
        ignoreCollisions: ignoreCollisions,
      ),
    );

    _addLinePathComponent();

    return _currentPath;
  }

  List<Vector2> getPathToPosition(
    Vector2 position, {
    List? ignoreCollisions,
  }) {
    _ignoreCollisions.clear();
    _ignoreCollisions.add(this);
    if (ignoreCollisions != null) {
      _ignoreCollisions.addAll(ignoreCollisions);
    }
    return _calculatePath(position);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_currentPath.isNotEmpty) {
      if (!moveToPosition(_currentPath[_currentIndex])) {
        _goToNextPosition();
      }
    }
  }

  @override
  void idle() {
    stopMoveAlongThePath();
    super.idle();
  }

  @override
  void renderTree(Canvas canvas) {
    _drawBarrries(canvas);
    super.renderTree(canvas);
  }

  void stopMoveAlongThePath() {
    _currentPath.clear();
    _barriers.clear();
    _currentIndex = 0;
    _removeLinePathComponent();
    _onFinish?.call();
    _onFinish = null;
  }

  List<Vector2> _calculatePath(Vector2 finalPosition) {
    final player = this;

    final positionPlayer = player.rectCollision.centerVector2;

    Point<int> playerPosition = _getCenterPositionByTile(positionPlayer);

    Point<int> targetPosition = _getCenterPositionByTile(finalPosition);

    double inflate = _tileSize * _factorInflateFindArea;

    int maxY = max(
      playerPosition.y,
      targetPosition.y,
    );

    int maxX = max(
      playerPosition.x,
      targetPosition.x,
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

    for (final e in gameRef.collisions(onlyVisible: _useOnlyVisibleBarriers)) {
      var rect = e.toAbsoluteRect();
      if (!_ignoreCollisions.contains(e) && area.overlaps(rect)) {
        _addCollisionOffsetsPositionByTile(rect);
      }
    }

    Iterable<Point<int>> result = [];

    if (_barriers.contains(targetPosition)) {
      stopMove();
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
        return _mapToWorldPositions(result);
      }
    } catch (e) {
      // ignore: avoid_print
      print('ERROR(AStar):$e');
    }
    return [];
  }

  /// Get size of the grid used on algorithm to calculate path
  double get _tileSize {
    double tileSize = 0.0;
    if (gameRef.map.tiles.isNotEmpty) {
      tileSize = gameRef.map.tiles.first.width;
    }
    if (_gridSizeIsCollisionSize) {
      final rect = rectCollision;
      return max(rect.height, rect.width) +
          REDUCTION_TO_AVOID_ROUNDING_PROBLEMS;
    }
    return tileSize;
  }

  bool get isMovingAlongThePath => _currentPath.isNotEmpty;

  Point<int> _getCenterPositionByTile(Vector2 center) {
    return Point(
      (center.x / _tileSize).floor(),
      (center.y / _tileSize).floor(),
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
      return Point<int>(
        (e.center.dx / _tileSize).floor(),
        (e.center.dy / _tileSize).floor(),
      );
    }).toList();

    for (var element in result) {
      if (!_barriers.contains(element)) {
        _barriers.add(element);
      }
    }
  }

  bool _isNeighbor(Point<int> playerPosition, Point<int> targetPosition) {
    if ((playerPosition.x - targetPosition.x).abs() == 1) {
      return true;
    }
    if ((playerPosition.y - targetPosition.y).abs() == 1) {
      return true;
    }
    return false;
  }

  void _goToNextPosition() {
    if (_currentIndex < _currentPath.length - 1) {
      _currentIndex++;
    } else {
      stopMove();
    }
  }

  void _drawBarrries(Canvas canvas) {
    if (_showBarriers) {
      for (var element in _barriers) {
        canvas.drawRect(
          Rect.fromLTWH(
            element.x * _tileSize,
            element.y * _tileSize,
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

  void _addLinePathComponent() {
    if (_linePathEnabled) {
      gameRef.add(
        _linePathComponent = LinePathComponent(
          _currentPath,
          _pathLineColor,
          _pathLineStrokeWidth,
        ),
      );
    }
  }

  List<Vector2> _mapToWorldPositions(Iterable<Point<int>> result) {
    return result.map((e) {
      return Vector2(e.x * _tileSize, e.y * _tileSize)
          .translated(_tileSize / 2, _tileSize / 2);
    }).toList();
  }
}
