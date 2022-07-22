import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/geometry/shape.dart';
import 'package:flutter/material.dart';

mixin Vision on GameComponent {
  static const VISION_360 = 6.28319;
  Map<String, PolygonShape> _polygonCache = Map();

  /// This method we notify when detect the component when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  Shape? seeComponent(
    GameComponent component, {
    required Function(GameComponent) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double? angleVision,
    double angle = 3.14159,
  }) {
    if (component.isRemoving) {
      notObserved?.call();
      return null;
    }

    String key = '$radiusVision/$angleVision/$angle';
    PolygonShape shape;
    if (_polygonCache.containsKey(key)) {
      shape = _polygonCache[key]!;
      shape.position = this.center;
    } else {
      shape = _buildShape(radiusVision, angleVision, angle, this.center);
      _polygonCache[key] = shape;
    }

    if (component.isRemoving) {
      notObserved?.call();
    }

    final rect = getRectAndCollision(component);
    final otherShape = RectangleShape(
      rect.sizeVector2,
      position: rect.positionVector2,
    );

    if (shape.isCollision(otherShape)) {
      observed(component);
    } else {
      notObserved?.call();
    }
    return shape;
  }

  /// This method we notify when detect components by type when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  Shape? seeComponentType<T extends GameComponent>({
    required Function(List<T>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double? angleVision,
    double angle = 3.14159,
  }) {
    var compVisible = this.gameRef.visibleComponents().where((element) {
      return element is T && element != this;
    }).cast<T>();

    if (compVisible.isEmpty) {
      notObserved?.call();
      return null;
    }

    String key = '$radiusVision/$angleVision/$angle';
    PolygonShape shape;
    if (_polygonCache.containsKey(key)) {
      shape = _polygonCache[key]!;
      shape.position = this.center;
    } else {
      shape = _buildShape(radiusVision, angleVision, angle, this.center);
      _polygonCache[key] = shape;
    }

    List<T> compObserved = compVisible.where((comp) {
      final rect = getRectAndCollision(comp);
      final otherShape = RectangleShape(
        rect.sizeVector2,
        position: rect.positionVector2,
      );
      return !comp.isRemoving && shape.isCollision(otherShape);
    }).toList();

    if (compObserved.isNotEmpty) {
      observed(compObserved);
    } else {
      notObserved?.call();
    }

    return shape;
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
}
