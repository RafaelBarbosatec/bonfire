import 'dart:ui';

import 'package:bonfire/bonfire.dart';

class CollisionConfig {
  /// Representing the collision area
  final Iterable<CollisionArea> collisions;

  bool collisionOnlyVisibleScreen = true;
  bool enable;

  Vector2? _lastPosition;

  Rect rect = Rect.zero;

  CollisionConfig({
    required this.collisions,
    this.enable = true,
  });

  bool verifyCollision(CollisionConfig? other, {Vector2? displacement}) {
    if (other != null) {
      for (final element1 in collisions) {
        for (final element2 in other.collisions) {
          if (displacement != null
              ? element1.verifyCollisionSimulate(displacement, element2)
              : element1.verifyCollision(element2)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void updatePosition(Vector2 position) {
    if (collisions.isNotEmpty && position != _lastPosition) {
      _lastPosition = position.clone();
      Rect? newRect;
      for (var element in collisions) {
        element.updatePosition(position);
        if (newRect == null) {
          newRect = element.rect;
        } else {
          newRect = newRect.expandToInclude(element.rect);
        }
      }
      rect = newRect!;
    }
  }
}
