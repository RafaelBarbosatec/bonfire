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
                  if (comp is BlockMovementCollision) {
                    comp.onMovementCollision(this, false);
                  }
                  return onMovementCollision(comp, true);
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

  /// if return `false` so the object will not collide with anything or block the passage.
  bool onMovementCollision(GameComponent component, bool active) {
    return true;
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
  void render(Canvas canvas) {
    super.render(canvas);
    if (gameRef.showCollisionArea) {
      renderCollision(
        canvas,
        gameRef.collisionAreaColor ?? Colors.lightGreen.withOpacity(0.5),
      );
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

  void renderCollision(Canvas canvas, Color color) {
    if (hasGameRef && containCollision()) {
      for (final element in hitboxList) {
        element.render(canvas);
      }
    }
  }
}
