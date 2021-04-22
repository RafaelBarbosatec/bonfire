import 'dart:ui';

import 'package:bonfire/gemonetry/retangle.dart';
import 'package:bonfire/gemonetry/shape.dart';
import 'package:bonfire/util/extensions.dart';
import 'package:flame/extensions.dart';

class CircleShape extends Shape {
  final double radius;
  final RectangleShape rect;
  Vector2 center;

  CircleShape(this.radius, {Vector2? position})
      : this.center = (position ?? Vector2.zero()).translate(radius, radius),
        this.rect = RectangleShape(
          Size(2 * radius, 2 * radius),
          position: position,
        ),
        super(position ?? Vector2.zero());

  @override
  set position(Vector2 value) {
    super.position = value;

    rect.position = value;
    center = value.translate(radius, radius);
  }

  @override
  void render(Canvas canvas, Paint paint) {
    canvas.drawCircle(
      position.toOffset(),
      radius,
      paint,
    );
  }
}
