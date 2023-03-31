import 'dart:async';

import 'package:bonfire/base/base_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// Mixin responsible for adding collision
mixin BlockMovementCollision on GameComponent {
  Iterable<ShapeHitbox> hitboxList = [];
  bool isCollision({Vector2? displacement}) {
    if (displacement != null) {
      if (hitboxList.isNotEmpty) {
        var dis = displacement - position;
        for (var hit in hitboxList) {
          var originalPosition = hit.position.clone();
          hit.position = originalPosition +
              Vector2(
                dis.x * (isFlippedHorizontally ? -1 : 1),
                dis.y * (isFlippedVertically ? -1 : 1),
              );

          for (var element in gameRef.visibleCollisions()) {
            if (element != hit) {
              var inter = (findGame() as BaseGame)
                  .collisionDetection
                  .intersections(element, hit);
              if (inter.isNotEmpty) {
                hit.position = originalPosition;
                var comp = element.parent;
                if (comp is GameComponent) {
                  return onComponentTypeCheck(comp);
                }
                return true;
              }
            }
          }
          hit.position = originalPosition;
        }
      }
    }

    return false;
  }

  Rect get rectCollision {
    if (hitboxList.isNotEmpty) {
      return hitboxList.fold(Rect.zero, (previousValue, element) {
        return previousValue.expandToInclude(element.toAbsoluteRect());
      });
    } else {
      return toAbsoluteRect();
    }
  }

  @override
  void update(double dt) {
    hitboxList = children.whereType<ShapeHitbox>();
    super.update(dt);
  }

  bool containCollision() {
    return hitboxList.isNotEmpty;
  }

  @override
  FutureOr<void> add(Component component) {
    if (gameRef.showCollisionArea && component is ShapeHitbox) {
      component.paint = Paint()
        ..color = gameRef.collisionAreaColor ?? Colors.white;
      component.renderShape = true;
    }
    return super.add(component);
  }
}
