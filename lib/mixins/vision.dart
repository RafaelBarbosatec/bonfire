import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/geometry/polygon.dart';
import 'package:bonfire/geometry/rectangle.dart';
import 'package:flutter/material.dart';

/// Mixin used to adds basic Vision to the component
mixin Vision on GameComponent {
  // ignore: constant_identifier_names
  static const VISION_360 = 6.28319;
  final Paint _paint = Paint()..color = Colors.red.withOpacity(0.5);
  bool _drawVision = false;
  bool _checkWithRaycast = true;
  final Map<String, PolygonShape> _polygonCache = {};
  PolygonShape? _currentShape;
  int _countPolygonPoints = 20;

  void setupVision({
    Color? color,
    bool drawVision = false,
    bool checkWithRaycast = true,
    int countPolygonPoints = 20,
  }) {
    assert(countPolygonPoints % 2 == 0, 'countPolygonPoints must be even');
    _drawVision = drawVision;
    _checkWithRaycast = checkWithRaycast;
    _countPolygonPoints = countPolygonPoints;
    _paint.color = color ?? Colors.red.withOpacity(0.5);
  }

  /// This method we notify when detect the component when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  /// [visionAngle] in radians
  /// [angle] in radians.
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

    PolygonShape shape = _getShapeVision(radiusVision, visionAngle, angle);

    if (_canSee(shape, component, radiusVision)) {
      observed(component);
    } else {
      notObserved?.call();
    }
    return _currentShape = shape;
  }

  bool _canSee(
    PolygonShape shape,
    GameComponent component,
    double radiusVision,
  ) {
    if (component.isRemoving) {
      return false;
    }

    final rect = component.rectCollision;
    final otherShape = RectangleShape(
      rect.sizeVector2,
      position: rect.positionVector2,
    );

    bool inShape = shape.isCollision(otherShape);
    if (inShape) {
      if (_checkWithRaycast) {
        Vector2 myCenter = rectCollision.center.toVector2();
        Vector2 compCenter = component.rectCollision.center.toVector2();
        Vector2 direction = (compCenter - myCenter).normalized();

        final result = raycast(
          direction,
          maxDistance: radiusVision,
          origin: myCenter,
        );
        return result?.hitbox?.parent == component;
      }
      return true;
    }

    return false;
  }

  /// This method we notify when detect components by type when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  /// [visionAngle] in radians
  /// [angle] in radians.
  PolygonShape? seeComponentType<T extends GameComponent>({
    required Function(List<T>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double? visionAngle,
    double angle = 3.14159,
  }) {
    var compVisible = gameRef.visibles<T>();

    if (compVisible.isEmpty) {
      notObserved?.call();
      return _currentShape = null;
    }

    PolygonShape shape = _getShapeVision(radiusVision, visionAngle, angle);

    List<T> compObserved = compVisible.where((comp) {
      return _canSee(shape, comp, radiusVision);
    }).toList();

    if (compObserved.isNotEmpty) {
      observed(compObserved);
    } else {
      notObserved?.call();
    }
    return _currentShape = shape;
  }

  PolygonShape _buildShape(
    double radiusVision,
    double? angleVision,
    double angle,
    Vector2 position,
  ) {
    double angleV = angleVision ?? VISION_360;
    double nextX = radiusVision * cos(angle);
    double nextY = radiusVision * sin(angle);
    Offset point = Offset(nextX, nextY);
    List<Vector2> pointsP = [];
    List.generate(_countPolygonPoints ~/ 2, (index) {
      if (index == 0) {
        pointsP.add(point
            .rotate(angleV / _countPolygonPoints, Offset.zero)
            .toVector2());
      } else {
        pointsP.add(pointsP.last
            .toOffset()
            .rotate(angleV / _countPolygonPoints, Offset.zero)
            .toVector2());
      }
    });
    List<Vector2> pointsN = [];
    List.generate(_countPolygonPoints ~/ 2, (index) {
      if (index == 0) {
        pointsN.add(point
            .rotate(angleV / -_countPolygonPoints, Offset.zero)
            .toVector2());
      } else {
        pointsN.add(pointsN.last
            .toOffset()
            .rotate(angleV / -_countPolygonPoints, Offset.zero)
            .toVector2());
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

  @override
  void onRemove() {
    cleanVisionCache();
    super.onRemove();
  }

  void cleanVisionCache() {
    _polygonCache.clear();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_drawVision) {
      canvas.save();
      canvas.translate(-position.x, -position.y);
      _currentShape?.render(canvas, _paint);
      canvas.restore();
    }
  }

  PolygonShape _getShapeVision(
    double radiusVision,
    double? visionAngle,
    double angle,
  ) {
    String key = '$radiusVision/$visionAngle/$angle';
    PolygonShape shape;
    var center = rectCollision.centerVector2;
    if (_polygonCache.containsKey(key)) {
      shape = _polygonCache[key]!;
      shape.position = center;
    } else {
      shape = _buildShape(radiusVision, visionAngle, angle, center);
      _polygonCache[key] = shape;
    }
    return shape;
  }
}
