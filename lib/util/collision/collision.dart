import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/widgets.dart';

class CollisionArea {
  double height;
  double width;
  final Offset align;

  CollisionArea({
    this.height = 0.0,
    this.width = 0.0,
    this.align = const Offset(0, 0),
  });

  CollisionArea.fromSize(double size, {this.align = const Offset(0, 0)})
      : height = size,
        width = size;

  Vector2Rect getVectorCollision(Vector2Rect displacement) {
    double left = displacement.rect.left + align.dx;
    double top = displacement.rect.top + align.dy;
    return Vector2Rect.fromRect(Rect.fromLTWH(left, top, width, height));
  }
}
