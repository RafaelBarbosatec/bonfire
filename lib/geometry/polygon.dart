import 'dart:ui';

import 'package:bonfire/geometry/rectangle.dart';
import 'package:bonfire/geometry/shape.dart';
import 'package:flame/extensions.dart';

class PolygonShape extends Shape {
  final List<Vector2> relativePoints;
  final List<Vector2> points;
  final RectangleShape rect;
  PolygonShape(this.relativePoints, {Vector2? position})
      : assert(relativePoints.length > 2),
        this.points = _initPoints(relativePoints, position ?? Vector2.zero()),
        this.rect = _initRect(relativePoints, position ?? Vector2.zero()),
        super(position ?? Vector2.zero());

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
    double height = 0;
    double width = 0;
    relativePoints.forEach((offset) {
      if (offset.x > width) {
        width = offset.x;
      }
      if (offset.y > height) {
        height = offset.y;
      }
    });

    return RectangleShape(Size(width, height), position: position);
  }

  @override
  set position(Vector2 value) {
    super.position = value;

    rect.position = value;
    for (var i = 0; i < points.length; i++) {
      points[i] = relativePoints[i] + value;
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
