import 'dart:ui';

import 'package:flame/components.dart';

/// Flame v1 relies a lot on Vector2 for position and dimensions
/// Bonfire instead relies a lot on Rect internally.
/// this class serves as a bridge between the two frameworks.
class Vector2Rect {
  final Vector2 position;
  final Vector2 size;

  final Rect rect;

  Vector2Rect(this.position, this.size)
      : rect = Rect.fromLTWH(
          position.x,
          position.y,
          size.x,
          size.y,
        );

  Vector2Rect.fromRect(this.rect)
      : position = Vector2(rect.left, rect.top),
        size = Vector2(rect.width, rect.height);

  Vector2Rect.zero() : this(Vector2.zero(), Vector2.zero());

  Vector2Rect translate(double translateX, double translateY) {
    return Vector2Rect(
      Vector2(this.position.x + translateX, this.position.y + translateY),
      this.size,
    );
  }

  /// Whether `other` has a nonzero area of overlap with this rectangle.
  bool overlaps(Vector2Rect vector) {
    return this.rect.overlaps(vector.rect);
  }

  bool contains(Offset offset) {
    return rect.contains(offset);
  }

  Vector2Rect shift(Offset offset) {
    return Vector2Rect(
      Vector2(this.position.x + offset.dx, this.position.y + offset.dy),
      this.size,
    );
  }

  Vector2Rect copyWith({
    Vector2? position,
    Vector2? size,
  }) {
    return Vector2Rect(
      position ?? this.position,
      size ?? this.size,
    );
  }

  Offset get offset => Offset(left, top);
  Offset get center => rect.center;
  double get left => rect.left;
  double get right => rect.right;
  double get top => rect.top;
  double get bottom => rect.bottom;
  double get height => rect.height;
  double get width => rect.width;
}
