import 'package:bonfire/base/base_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// Mixin responsible for adding collision
mixin BlockMovementCollision on GameComponent {
  // ignore: non_constant_identifier_names
  final Map<Vector2, Rect> _RECT_CACHE = {};
  Iterable<ShapeHitbox> _hitboxList = [];

  void onMovementCollision(GameComponent other, bool active) {}

  bool isCollision({Vector2? displacement}) {
    if (displacement != null) {
      if (_hitboxList.isNotEmpty) {
        var dis = displacement - position;
        for (var hit in _hitboxList) {
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
                bool collision = false;
                if (comp is GameComponent) {
                  bool colisionComp = comp.onComponentTypeCheck(this);
                  bool colisionComp2 = onComponentTypeCheck(comp);
                  collision = colisionComp && colisionComp2;
                  if (collision) {
                    onMovementCollision(comp, true);
                    if (comp is BlockMovementCollision) {
                      comp.onMovementCollision(this, false);
                    }
                  }
                }
                return collision;
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
    if (!_RECT_CACHE.containsKey(position)) {
      _RECT_CACHE.clear();
      var rect = toAbsoluteRect();
      if (_hitboxList.isNotEmpty) {
        var colissionRect = _hitboxList.fold(_hitboxList.first.toRect(),
            (previousValue, element) {
          return previousValue.expandToInclude(element.toRect());
        });
        return _RECT_CACHE[position] = Rect.fromLTWH(
          rect.left + colissionRect.left,
          rect.top + colissionRect.top,
          colissionRect.width,
          colissionRect.height,
        );
      } else {
        return _RECT_CACHE[position] = rect;
      }
    } else {
      return _RECT_CACHE[position]!;
    }
  }

  @override
  void update(double dt) {
    _hitboxList = children.whereType<ShapeHitbox>();
    super.update(dt);
  }

  bool containCollision() {
    return _hitboxList.isNotEmpty;
  }
}
