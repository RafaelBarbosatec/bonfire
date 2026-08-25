import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/geometry/polygon.dart';
import 'package:bonfire/geometry/rectangle.dart';
import 'package:bonfire/util/extensions/color_extensions.dart';
import 'package:flutter/material.dart';

/// Mixin that marks a component as invisible to the [WithVision] detection.
mixin CanNotSeen on GameComponent {}

/// API for managing vision/line-of-sight behavior.
class VisionApi {
  // ignore: constant_identifier_names
  static const VISION_360 = 6.28319;

  final GameComponent _comp;

  final Paint _paint = Paint()..color = Colors.red.setOpacity(0.5);
  bool _drawVision = false;
  bool _checkWithRaycast = true;
  final Map<String, PolygonShape> _polygonCache = {};
  PolygonShape? _currentShape;
  int _countPolygonPoints = 20;

  VisionApi(this._comp);

  void setup({
    Color? color,
    bool drawVision = false,
    bool checkWithRaycast = true,
    int countPolygonPoints = 20,
  }) {
    assert(countPolygonPoints.isEven, 'countPolygonPoints must be even');
    _drawVision = drawVision;
    _checkWithRaycast = checkWithRaycast;
    _countPolygonPoints = countPolygonPoints;
    _paint.color = color ?? Colors.red.setOpacity(0.5);
  }

  /// Checks if [component] is within vision range.
  /// [visionAngle] in radians. [angle] in radians.
  PolygonShape? seeComponent(
    GameComponent component, {
    required Function(GameComponent) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double? visionAngle,
    double angle = 3.14159,
  }) {
    if (component.isRemoving) {
      notObserved?.call();
      return _currentShape = null;
    }

    final shape = _getShapeVision(radiusVision, visionAngle, angle);

    if (_canSee(shape, component, radiusVision)) {
      observed(component);
    } else {
      notObserved?.call();
    }
    return _currentShape = shape;
  }

  /// Checks if any component of type [T] is within vision range.
  /// [visionAngle] in radians. [angle] in radians.
  PolygonShape? seeComponentType<T extends GameComponent>({
    required void Function(List<T>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double? visionAngle,
    double angle = 3.14159,
  }) {
    final compVisible = _comp.gameRef.visibles<T>();

    if (compVisible.isEmpty) {
      notObserved?.call();
      return _currentShape = null;
    }

    final shape = _getShapeVision(radiusVision, visionAngle, angle);

    final compObserved = compVisible.where((c) {
      return _canSee(shape, c, radiusVision);
    }).toList();

    if (compObserved.isNotEmpty) {
      observed(compObserved);
    } else {
      notObserved?.call();
    }
    return _currentShape = shape;
  }

  /// Checks if the player is within vision range.
  /// [visionAngle] in radians. [angle] in radians.
  PolygonShape? seePlayer({
    required Function(Player) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
  }) {
    final player = _comp.gameRef.player;
    if (player == null || player.isDead) {
      notObserved?.call();
      return null;
    }
    return seeComponent(
      player,
      observed: (c) => observed(c as Player),
      notObserved: notObserved,
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? _defaultAngle(),
    );
  }

  /// Checks if the player is within range. If so, move to it.
  /// [visionAngle] in radians. [angle] in radians.
  PolygonShape? seeAndMoveToPlayer({
    Function(Player)? closePlayer,
    // return true to stop move.
    BoolCallback? notObserved,
    VoidCallback? observed,
    VoidCallback? notCanMove,
    double radiusVision = 32,
    double margin = 2,
    double? visionAngle,
    double? angle,
    bool runOnlyVisibleInScreen = true,
    MovementAxis movementAxis = MovementAxis.all,
  }) {
    if (runOnlyVisibleInScreen && !_comp.isVisible) {
      return null;
    }

    return seePlayer(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle,
      observed: (player) {
        observed?.call();
        final movement = _movement;
        if (movement == null) {
          return;
        }
        final move = movement.moveTowardsTarget(
          target: player,
          close: () => closePlayer?.call(player),
          margin: margin,
          movementAxis: movementAxis,
        );
        if (!move) {
          notCanMove?.call();
        }
      },
      notObserved: () {
        final canStop = notObserved?.call() ?? true;
        if (canStop) {
          _movement?.stop();
        }
      },
    );
  }

  /// Checks whether the enemy is within range. If so, move to it.
  /// [visionAngle] in radians. [angle] in radians.
  void seeAndMoveToEnemy({
    required Function(Enemy) closeEnemy,
    // return true to stop move.
    BoolCallback? notObserved,
    VoidCallback? observed,
    VoidCallback? notCanMove,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
    MovementAxis movementAxis = MovementAxis.all,
  }) {
    if (runOnlyVisibleInScreen && !_comp.isVisible) {
      return;
    }

    seeComponentType<Enemy>(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? _defaultAngle(),
      observed: (enemy) {
        observed?.call();
        final movement = _movement;
        if (movement == null) {
          return;
        }
        final move = movement.moveTowardsTarget(
          target: enemy.first,
          close: () {
            closeEnemy(enemy.first);
          },
          margin: margin,
          movementAxis: movementAxis,
        );
        if (!move) {
          notCanMove?.call();
        }
      },
      notObserved: () {
        final canStop = notObserved?.call() ?? true;
        if (canStop) {
          _movement?.stop();
        }
      },
    );
  }

  /// Checks whether the ally is within range. If so, move to it.
  /// [visionAngle] in radians. [angle] in radians.
  void seeAndMoveToAlly({
    required Function(Ally) closeAlly,
    // return true to stop move.
    BoolCallback? notObserved,
    VoidCallback? observed,
    VoidCallback? notCanMove,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double margin = 10,
    bool runOnlyVisibleInScreen = true,
    MovementAxis movementAxis = MovementAxis.all,
  }) {
    if (runOnlyVisibleInScreen && !_comp.isVisible) {
      return;
    }

    seeComponentType<Ally>(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? _defaultAngle(),
      observed: (ally) {
        observed?.call();
        final movement = _movement;
        if (movement == null) {
          return;
        }
        final move = movement.moveTowardsTarget(
          target: ally.first,
          close: () {
            closeAlly(ally.first);
          },
          movementAxis: movementAxis,
          margin: margin,
        );
        if (!move) {
          notCanMove?.call();
        }
      },
      notObserved: () {
        final canStop = notObserved?.call() ?? true;
        if (canStop) {
          _movement?.stop();
        }
      },
    );
  }

  /// Checks if any enemy is within vision range.
  /// [visionAngle] in radians. [angle] in radians.
  PolygonShape? seeEnemy({
    required Function(List<Enemy>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
  }) {
    if (_comp is WithLife && _comp.isDead) {
      return null;
    }
    return seeComponentType<Enemy>(
      observed: observed,
      notObserved: notObserved,
      radiusVision: radiusVision,
      angle: angle ?? _defaultAngle(),
      visionAngle: visionAngle,
    );
  }

  /// Checks whether the [T] components are within attack range. If so, move to
  /// them and call [positioned] when in range.
  /// [visionAngle] in radians. [angle] in radians.
  void seeAndMoveToAttackRange<T extends GameComponent>({
    Function(T)? positioned,
    // return true to stop move.
    BoolCallback? notObserved,
    Function(T)? observed,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
    double? minDistanceFromPlayer,
    bool useDiagonal = true,
  }) {
    if (_comp is WithLife && _comp.isDead) {
      return;
    }

    seeComponentType<T>(
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      angle: angle ?? _defaultAngle(),
      observed: (targets) {
        final target = targets.first;
        observed?.call(target);
        final minD = minDistanceFromPlayer ?? (radiusVision - 5);
        final movement = _movement;
        if (movement == null) {
          return;
        }
        if (useDiagonal) {
          final inDistance = movement.keepDistance(target, minD);
          if (inDistance) {
            movement.direction = movement.util.getDirectionToTarget(target);
            if (!movement.isIdle) {
              movement.stop();
            }
            positioned?.call(target);
          }
        } else {
          movement.positionsItselfAndKeepDistance(
            target,
            minDistanceFromPlayer: minD,
            radiusVision: radiusVision,
            positioned: (t) {
              movement.direction = movement.util.getDirectionToTarget(t);
              if (!movement.isIdle) {
                movement.stop();
              }
              positioned?.call(t);
            },
          );
        }
      },
      notObserved: () {
        final canStop = notObserved?.call() ?? true;
        if (canStop) {
          _movement?.stop();
        }
      },
    );
  }

  /// Clears the cached vision polygon shapes.
  void cleanCache() {
    _polygonCache.clear();
  }

  /// Renders the vision shape if [drawVision] is enabled.
  void render(Canvas canvas) {
    if (_drawVision) {
      canvas.save();
      canvas.translate(-_comp.position.x, -_comp.position.y);
      _currentShape?.render(canvas, _paint);
      canvas.restore();
    }
  }

  Movement? get _movement => _comp is Movement ? _comp : null;

  double _defaultAngle() {
    return _comp is Movement ? _comp.direction.toRadians() : 3.14159;
  }

  bool _canSee(
    PolygonShape shape,
    GameComponent component,
    double radiusVision,
  ) {
    if (component.isRemoving || component is CanNotSeen) {
      return false;
    }

    final rect = component.rectCollision;
    final otherShape = RectangleShape(
      rect.sizeVector2,
      position: rect.positionVector2,
    );

    final inShape = shape.isCollision(otherShape);
    if (inShape) {
      if (_checkWithRaycast) {
        final myCenter = _comp.rectCollision.center.toVector2();
        final compCenter = component.rectCollision.center.toVector2();
        final direction = (compCenter - myCenter).normalized();

        final result = _comp.raycast(
          direction,
          maxDistance: radiusVision,
          origin: myCenter,
          ignoreHitboxes: _getCanNotSeenHitbox(),
        );
        final vParent = result?.hitbox?.parent;
        return vParent == component || vParent == null;
      }
      return true;
    }

    return false;
  }

  PolygonShape _getShapeVision(
    double radiusVision,
    double? visionAngle,
    double angle,
  ) {
    final key = '$radiusVision/$visionAngle/$angle';
    PolygonShape shape;
    final center = _comp.rectCollision.centerVector2;
    if (_polygonCache.containsKey(key)) {
      shape = _polygonCache[key]!;
      shape.position = center;
    } else {
      shape = _buildShape(radiusVision, visionAngle, angle, center);
      _polygonCache[key] = shape;
    }
    return shape;
  }

  PolygonShape _buildShape(
    double radiusVision,
    double? angleVision,
    double angle,
    Vector2 position,
  ) {
    final angleV = angleVision ?? VISION_360;
    final nextX = radiusVision * cos(angle);
    final nextY = radiusVision * sin(angle);
    final point = Offset(nextX, nextY);
    final pointsP = <Vector2>[];
    List.generate(_countPolygonPoints ~/ 2, (index) {
      if (index == 0) {
        pointsP.add(
          point.rotate(angleV / _countPolygonPoints, Offset.zero).toVector2(),
        );
      } else {
        pointsP.add(
          pointsP.last
              .toOffset()
              .rotate(angleV / _countPolygonPoints, Offset.zero)
              .toVector2(),
        );
      }
    });
    final pointsN = <Vector2>[];
    List.generate(_countPolygonPoints ~/ 2, (index) {
      if (index == 0) {
        pointsN.add(
          point.rotate(angleV / -_countPolygonPoints, Offset.zero).toVector2(),
        );
      } else {
        pointsN.add(
          pointsN.last
              .toOffset()
              .rotate(angleV / -_countPolygonPoints, Offset.zero)
              .toVector2(),
        );
      }
    });

    return PolygonShape(
      [
        Vector2(0, 0),
        ...pointsP.reversed,
        point.toVector2(),
        ...pointsN,
      ],
      position: position,
    );
  }

  List<ShapeHitbox> _getCanNotSeenHitbox() {
    final sensorHitBox = <ShapeHitbox>[];
    _comp.gameRef.query<CanNotSeen>(onlyVisible: true).forEach((e) {
      sensorHitBox.addAll(e.children.query<ShapeHitbox>());
    });
    return sensorHitBox;
  }
}
