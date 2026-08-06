// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'dart:ui';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/extensions/color_extensions.dart';
import 'package:bonfire/util/extensions/int_int_extensions.dart';
import 'package:bonfire/util/line_path_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Callback fired when the component finishes moving along the path.
typedef PathFindingFinishCallback = void Function();

/// API responsible for finding paths using A* and moving the component
/// through them.
///
/// The parent component must have a [Movement] mixin.
class PathFindingApi {
  final Movement comp;

  static const REDUCTION_TO_AVOID_ROUNDING_PROBLEMS = 4;

  List<Vector2> _currentPath = [];
  int _currentIndex = 0;
  bool _linePathEnabled = true;
  bool _showBarriers = false;
  bool _gridSizeIsCollisionSize = false;
  bool _useOnlyVisibleBarriers = true;
  bool _withDiagonal = true;
  bool _useAreaBetweenPlayerAndTarget = false;
  double _factorInflateFindArea = 2;

  final List<(int, int)> _barriers = [];
  final List<ShapeHitbox> _ignoreCollisions = [];

  LinePathComponent? _linePathComponent;
  Color _pathLineColor = const Color(0xFF40C4FF).setOpacity(0.5);
  double _pathLineStrokeWidth = 4;
  final Paint _paintShowBarriers = Paint()
    ..color = const Color(0xFF2196F3).setOpacity(0.5);

  final List<PathFindingFinishCallback> _onFinishCallbacks = [];

  PathFindingApi(this.comp);

  /// Whether the component is currently moving along a path.
  bool get isMoving => _currentPath.isNotEmpty;

  /// Registers a callback fired when the component reaches the path end.
  void onFinishListener(PathFindingFinishCallback callback) {
    _onFinishCallbacks.add(callback);
  }

  /// Sets up path finding visuals and behavior.
  void setup({
    bool? linePathEnabled,

    /// Use to set line path color
    Color? pathLineColor,
    Color? barriersCalculatedColor,

    /// Use to set line path width
    double pathLineStrokeWidth = 4,

    /// Use to debug and show area collision calculated
    bool showBarriersCalculated = false,
    bool useOnlyVisibleBarriers = true,
    bool useAreaBetweenPlayerAndTarget = false,

    /// If `false` the algorithm use map tile size with base of the grid.
    ///  if true this use collision size of the component.
    bool gridSizeIsCollisionSize = false,
    bool withDiagonal = true,
    double factorInflateFindArea = 2,
  }) {
    _useAreaBetweenPlayerAndTarget = useAreaBetweenPlayerAndTarget;
    _withDiagonal = withDiagonal;
    _linePathEnabled = linePathEnabled ?? _linePathEnabled;
    _useOnlyVisibleBarriers = useOnlyVisibleBarriers;
    _factorInflateFindArea = factorInflateFindArea;
    _paintShowBarriers.color =
        barriersCalculatedColor ?? const Color(0xFF2196F3).setOpacity(0.5);
    _showBarriers = showBarriersCalculated;

    _pathLineColor = pathLineColor ?? _pathLineColor;
    _pathLineStrokeWidth = pathLineStrokeWidth;
    _pathLineColor = pathLineColor ?? const Color(0xFF40C4FF).setOpacity(0.5);
    _gridSizeIsCollisionSize = gridSizeIsCollisionSize;
  }

  /// Moves the component to [position] using A* path finding.
  Future<List<Vector2>> moveToPosition(
    Vector2 position, {
    List<GameComponent>? ignoreCollisions,
    VoidCallback? onFinish,
  }) async {
    if (!comp.hasGameRef) {
      return Future.value([]);
    }

    if (onFinish != null) {
      _onFinishCallbacks.add(onFinish);
    }
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

  /// Makes the component follow a previously calculated [path].
  void moveAlongThePath(
    List<Vector2> path, {
    VoidCallback? onFinish,
  }) {
    if (!comp.hasGameRef) {
      return;
    }

    if (onFinish != null) {
      _onFinishCallbacks.add(onFinish);
    }
    _currentIndex = 0;
    _removeLinePathComponent();

    _currentPath = path;
    _addLinePathComponent();
  }

  /// Returns the path to [position] without moving the component.
  List<Vector2> getPathToPosition(
    Vector2 position, {
    List<GameComponent>? ignoreCollisions,
  }) {
    _ignoreCollisions.clear();
    _ignoreCollisions.addAll(comp.shapeHitboxes);

    ignoreCollisions?.forEach(
      (item) => _ignoreCollisions.addAll(item.shapeHitboxes),
    );
    return _calculatePath(position);
  }

  /// Updates path following movement.
  void update(double dt) {
    if (_currentPath.isNotEmpty) {
      if (!comp.moveToPosition(_currentPath[_currentIndex])) {
        _goToNextPosition();
      }
    }
  }

  /// Renders debug barriers if enabled.
  void render(Canvas canvas) {
    _drawBarriers(canvas);
  }

  /// Stops following the current path.
  void stop() {
    _currentPath.clear();
    _barriers.clear();
    _currentIndex = 0;
    _removeLinePathComponent();
    _notifyFinish();
    comp.stop();
  }

  /// Cleans up path line component when the component is removed.
  void dispose() {
    _removeLinePathComponent();
    _onFinishCallbacks.clear();
  }

  List<Vector2> _calculatePath(Vector2 finalPosition) {
    final positionPlayer = comp.rectCollision.centerVector2;

    final playerPosition = _getCenterPositionByTile(positionPlayer);

    final targetPosition = _getCenterPositionByTile(finalPosition);

    final inflate = _tileSize * _factorInflateFindArea;

    final int maxY = max(
      playerPosition.y,
      targetPosition.y,
    );

    final int maxX = max(
      playerPosition.x,
      targetPosition.x,
    );

    final rows = maxY + inflate.toInt();

    final columns = maxX + inflate.toInt();

    _barriers.clear();

    var area = Rect.fromPoints(
      positionPlayer.toOffset(),
      finalPosition.toOffset(),
    );

    var left = area.left;
    var right = area.right;
    var top = area.top;
    var bottom = area.bottom;
    final double size = max(area.width, area.height);
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

    for (final e in comp.gameRef.collisions(onlyVisible: _useOnlyVisibleBarriers)) {
      if (!_ignoreCollisions.contains(e)) {
        final rect = e.toAbsoluteRect();
        if (area.overlaps(rect) || !_useAreaBetweenPlayerAndTarget) {
          _addCollisionOffsetsPositionByTile(rect);
        }
      }
    }

    Iterable<(int, int)> result = [];

    if (_barriers.contains(targetPosition)) {
      comp.stop();
      return [];
    }

    try {
      result = AStar(
        rows: rows + 1,
        columns: columns + 1,
        start: playerPosition,
        end: targetPosition,
        barriers: _barriers,
        withDiagonal: _withDiagonal,
      ).findThePath();

      if (result.isNotEmpty || _isNeighbor(playerPosition, targetPosition)) {
        result = AStar.simplifyPath(result);
        return _mapToWorldPositions(result);
      } else {
        comp.stop();
        return [];
      }
    } catch (e, stacktrace) {
      // ignore: avoid_print
      print('ERROR(AStar):$e | $stacktrace');
    }
    return [];
  }

  /// Get size of the grid used on algorithm to calculate path
  double get _tileSize {
    final tileSize = comp.gameRef.map.tileSize;
    if (_gridSizeIsCollisionSize) {
      final rect = comp.rectCollision;
      return max(rect.height, rect.width) +
          REDUCTION_TO_AVOID_ROUNDING_PROBLEMS;
    }
    return tileSize;
  }

  (int, int) _getCenterPositionByTile(Vector2 center) {
    return (
      (center.x / _tileSize).floor(),
      (center.y / _tileSize).floor(),
    );
  }

  /// creating an imaginary grid would calculate how many tile
  ///  this object is occupying.
  void _addCollisionOffsetsPositionByTile(Rect rect) {
    final leftTop = Offset(
      (rect.left / _tileSize).floor() * _tileSize,
      (rect.top / _tileSize).floor() * _tileSize,
    );

    final grid = <Rect>[];
    final countColumns = (rect.width / _tileSize).ceil() + 1;
    final countRows = (rect.height / _tileSize).ceil() + 1;

    List.generate(countRows, (r) {
      List.generate(countColumns, (c) {
        grid.add(
          Rect.fromLTWH(
            leftTop.dx +
                (c * _tileSize) +
                REDUCTION_TO_AVOID_ROUNDING_PROBLEMS / 2,
            leftTop.dy +
                (r * _tileSize) +
                REDUCTION_TO_AVOID_ROUNDING_PROBLEMS / 2,
            _tileSize - REDUCTION_TO_AVOID_ROUNDING_PROBLEMS,
            _tileSize - REDUCTION_TO_AVOID_ROUNDING_PROBLEMS,
          ),
        );
      });
    });

    final listRect = grid.where((element) {
      return rect.overlaps(element);
    }).toList();

    final result = listRect.map((e) {
      return (
        (e.center.dx / _tileSize).floor(),
        (e.center.dy / _tileSize).floor(),
      );
    }).toList();

    for (final element in result) {
      if (!_barriers.contains(element)) {
        _barriers.add(element);
      }
    }
  }

  bool _isNeighbor((int, int) playerPosition, (int, int) targetPosition) {
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
      stop();
    }
  }

  void _drawBarriers(Canvas canvas) {
    if (_showBarriers) {
      for (final element in _barriers) {
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

  void _removeLinePathComponent() {
    _linePathComponent?.removeFromParent();
    _linePathComponent = null;
  }

  void _addLinePathComponent() {
    if (_linePathEnabled) {
      comp.gameRef.add(
        _linePathComponent = LinePathComponent(
          _currentPath,
          _pathLineColor,
          _pathLineStrokeWidth,
        ),
      );
    }
  }

  List<Vector2> _mapToWorldPositions(Iterable<(int, int)> result) {
    return result.map((e) {
      return Vector2(e.x * _tileSize, e.y * _tileSize)
          .translated(_tileSize / 2, _tileSize / 2);
    }).toList();
  }

  void _notifyFinish() {
    for (final callback in _onFinishCallbacks) {
      callback();
    }
    _onFinishCallbacks.clear();
  }
}
