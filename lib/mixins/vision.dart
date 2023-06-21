import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/geometry/polygon.dart';
import 'package:bonfire/geometry/rectangle.dart';
import 'package:flutter/material.dart';

mixin Vision on GameComponent {
  // ignore: constant_identifier_names
  static const VISION_360 = 6.28319;
  final Paint _paint = Paint()..color = Colors.red.withOpacity(0.5);
  bool _drawVision = false;
  final Map<String, PolygonShape> _polygonCache = {};
  PolygonShape? _currentShape;

  void setupVision({Color? color, bool drawVision = false}) {
    _drawVision = drawVision;
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

    if (_canSee(shape, component)) {
      observed(component);
    } else {
      notObserved?.call();
    }
    return _currentShape = shape;
  }

  bool _canSee(PolygonShape shape, GameComponent component) {
    if (component.isRemoving) {
      return false;
    }

    final rect = component.rectConsideringCollision;
    final otherShape = RectangleShape(
      rect.sizeVector2,
      position: rect.positionVector2,
    );

    return shape.isCollision(otherShape);
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
      return _canSee(shape, comp);
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
    Offset point1 = point.rotate(angleV / 8, Offset.zero);
    Offset point2 = point1.rotate(angleV / 8, Offset.zero);
    Offset point3 = point2.rotate(angleV / 8, Offset.zero);
    Offset point4 = point3.rotate(angleV / 8, Offset.zero);
    Offset point5 = point.rotate(angleV / -8, Offset.zero);
    Offset point6 = point5.rotate(angleV / -8, Offset.zero);
    Offset point7 = point6.rotate(angleV / -8, Offset.zero);
    Offset point8 = point7.rotate(angleV / -8, Offset.zero);
    return PolygonShape(
      [
        Vector2(0, 0),
        point4.toVector2(),
        point3.toVector2(),
        point2.toVector2(),
        point1.toVector2(),
        point.toVector2(),
        point5.toVector2(),
        point6.toVector2(),
        point7.toVector2(),
        point8.toVector2(),
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
      _currentShape?.render(canvas, _paint);
    }
  }

  PolygonShape _getShapeVision(
    double radiusVision,
    double? visionAngle,
    double angle,
  ) {
    String key = '$radiusVision/$visionAngle/$angle';
    PolygonShape shape;
    var center = absoluteCenter;
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
