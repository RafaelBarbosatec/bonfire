import 'dart:ui';

import 'package:bonfire/geometry/rectangle.dart';
import 'package:bonfire/geometry/shape.dart';
import 'package:flame/extensions.dart';

class CircleShape extends Shape {
  final double radius;
  final RectangleShape rect;
  Vector2 center;
  Offset offsetToDraw;

  CircleShape(this.radius, {Vector2? position})
      : center = (position ?? Vector2.zero()).translated(radius, radius),
        offsetToDraw = Offset(
          (position ?? Vector2.zero()).x + radius,
          (position ?? Vector2.zero()).y + radius,
        ),
        rect = RectangleShape(
          Vector2(2 * radius, 2 * radius),
          position: position,
        ),
        super(position ?? Vector2.zero());

  @override
  set position(Vector2 value) {
    if (value != super.position) {
      super.position = value;
      rect.position = value;
      center = value.translated(radius, radius);
      offsetToDraw = Offset(position.x + radius, position.y + radius);
    }
  }

  @override
  void render(Canvas canvas, Paint paint) {
    canvas.drawCircle(
      Offset(position.x + radius, position.y + radius),
      radius,
      paint,
    );
  }
}
