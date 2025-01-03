import 'dart:ui';

import 'package:bonfire/geometry/rectangle.dart';
import 'package:bonfire/geometry/shape.dart';
import 'package:flame/extensions.dart';

class PolygonShape extends Shape {
  final List<Vector2> relativePoints;
  final List<Vector2> points;
  final RectangleShape rect;
  double _minX = 0;
  double _minY = 0;
  PolygonShape(this.relativePoints, {Vector2? position})
      : assert(relativePoints.length > 2),
        points = _initPoints(relativePoints, position ?? Vector2.zero()),
        rect = _initRect(relativePoints, position ?? Vector2.zero()),
        super(position ?? Vector2.zero()) {
    _minX = rect.position.x - (position?.x ?? 0);
    _minY = rect.position.y - (position?.y ?? 0);
  }

  static List<Vector2> _initPoints(
    List<Vector2> relativePoints,
    Vector2 position,
  ) {
    final list = <Vector2>[];
    for (var i = 0; i < relativePoints.length; i++) {
      list.add(relativePoints[i] + position);
    }
    return list;
  }

  static RectangleShape _initRect(
    List<Vector2> relativePoints,
    Vector2 position,
  ) {
    var height = 0.0;
    var width = 0.0;

    var minX = relativePoints.first.x;
    var maxX = relativePoints.first.x;

    var minY = relativePoints.first.y;
    var maxY = relativePoints.first.y;
    for (final offset in relativePoints) {
      if (offset.x < minX) {
        minX = offset.x;
      }
      if (offset.x > maxX) {
        maxX = offset.x;
      }
      if (offset.y < minY) {
        minY = offset.y;
      }
      if (offset.y > maxY) {
        maxY = offset.y;
      }
    }

    height = maxY - minY;
    width = maxX - minX;

    return RectangleShape(
      Vector2(width, height),
      position: Vector2(position.x + minX, position.y + minY),
    );
  }

  @override
  set position(Vector2 value) {
    if (value != position) {
      super.position = value;

      for (var i = 0; i < points.length; i++) {
        points[i] = relativePoints[i] + value;
      }

      rect.position = Vector2(value.x + _minX, value.y + _minY);
    }
  }

  @override
  void render(Canvas canvas, Paint paint) {
    if (points.isNotEmpty) {
      paint.style = PaintingStyle.fill;
      final path = Path()..moveTo(points.first.x, points.first.y);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].x, points[i].y);
      }
      path.lineTo(points.first.x, points.first.y);

      canvas.drawPath(path, paint);
    }
  }
}
