import 'dart:ui';

import 'package:bonfire/util/vector2rect.dart';

import 'collision_area.dart';

class CollisionConfig {
  /// Representing the collision area
  final Iterable<CollisionArea> collisions;

  bool collisionOnlyVisibleScreen = true;
  bool enable;

  Rect _rect = Rect.zero;

  Vector2Rect? _lastPosition;

  CollisionConfig({
    required this.collisions,
    this.enable = true,
  });

  Rect get rect => _rect;

  bool verifyCollision(CollisionConfig? other) {
    if (other == null) return false;
    if (rect.overlaps(other.rect)) {
      for (final element1 in collisions) {
        for (final element2 in other.collisions) {
          if (element1.verifyCollision(element2)) {
            return true;
          }
        }
      }
      return false;
    } else {
      return false;
    }
  }

  void updatePosition(Vector2Rect position) {
    if (collisions.isNotEmpty && position != _lastPosition) {
      collisions.first.updatePosition(position);
      _rect = collisions.first.rect;
      for (final element in collisions) {
        element.updatePosition(position);
        _rect = _rect.expandToInclude(element.rect);
      }
      _lastPosition = position;
    }
  }
}
