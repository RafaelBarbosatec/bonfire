import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/widgets.dart';

Paint _paintCollision = Paint();

class CollisionArea {
  final Shape shape;
  final Vector2? align;

  CollisionArea({
    required this.shape,
    Vector2? align,
  }) : align = align ?? Vector2.zero();

  CollisionArea.rectangle({
    required Vector2 size,
    Vector2? align,
  })  : shape = Rectangle(size: size),
        align = align ?? Vector2.zero();

  CollisionArea.circle({
    required double radius,
    Vector2? align,
  })  : shape = Circle(radius: radius),
        align = align ?? Vector2.zero();

  CollisionArea.polygon({
    required List<Vector2> points,
    Vector2? align,
  })  : shape = Polygon(points),
        align = align ?? Vector2.zero();

  CollisionArea.fromVector2Rect({
    required Vector2Rect rect,
    Vector2? align,
  })  : shape = Rectangle(size: rect.size),
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
    if (rect.overlaps(other.rect)) {
      return shape.intersections(other.shape).isNotEmpty;
    } else {
      return false;
    }
  }

  Rect get rect => Rect.fromLTWH(
        shape.position.x,
        shape.position.y,
        (shape.size?.x ?? 0.0),
        (shape.size?.y ?? 0.0),
      );
}
