import 'package:bonfire/bonfire.dart';
import 'package:bonfire/geometry/shape.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/widgets.dart';

Paint _paintCollision = Paint();

class CollisionArea {
  final Shape shape;
  final Vector2? align;

  CollisionArea.rectangle({
    required Size size,
    Vector2? align,
  })  : shape = RectangleShape(size),
        align = align ?? Vector2.zero();

  CollisionArea.circle({
    required double radius,
    Vector2? align,
  })  : shape = CircleShape(radius),
        align = align ?? Vector2.zero();

  CollisionArea.polygon({
    required List<Vector2> points,
    Vector2? align,
  })  : shape = PolygonShape(points),
        align = align ?? Vector2.zero();

  CollisionArea.fromVector2Rect({
    required Vector2Rect rect,
    Vector2? align,
  })  : shape = RectangleShape(Size(rect.size.x, rect.size.y)),
        align = align ?? Vector2.zero();

  void updatePosition(Vector2Rect position) {
    double x = position.position.x;
    double y = position.position.y;
    x += (align?.x ?? 0.0);
    y += (align?.y ?? 0.0);
    shape.position = Vector2(x, y);
  }

  void render(Canvas c, Color color) {
    shape.render(c, _paintCollision..color = color);
  }

  bool verifyCollision(CollisionArea other) {
    return shape.isCollision(other.shape);
  }

  Rect get rect {
    if (shape is CircleShape) {
      return (shape as CircleShape).rect.rect;
    }

    if (shape is RectangleShape) {
      return (shape as RectangleShape).rect;
    }

    if (shape is PolygonShape) {
      return (shape as PolygonShape).rect.rect;
    }

    return Rect.zero;
  }
}
