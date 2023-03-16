import 'package:bonfire/base/base_game.dart';
import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding collision
mixin ObjectCollision on GameComponent {
  CollisionConfig? _collisionConfig;

  CollisionConfig? get collisionConfig => _collisionConfig;

  final bool _containCollision = false;

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    // if (other is ScreenHitbox) {
    //   //...
    // } else if (other is YourOtherComponent) {
    //   //...
    // }
    // print('onCollision : ($this) -> ($other)');
    super.onCollision(points, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    // if (other is ScreenHitbox) {
    //   //...
    // } else if (other is YourOtherComponent) {
    //   //...
    // }
    super.onCollisionEnd(other);
  }

  bool isCollision({Vector2? displacement}) {
    if (displacement != null) {
      final hit = children.whereType<ShapeHitbox>().first;
      var dis = displacement - position;

      hit.position = Vector2(
        dis.x * (isFlippedHorizontally ? -1 : 1),
        dis.y * (isFlippedVertically ? -1 : 1),
      );
      for (var element in (gameRef as BaseGame).collisionDetection.items) {
        if (element != hit) {
          var inter = (findGame() as BaseGame)
              .collisionDetection
              .intersections(element, hit);
          if (inter.isNotEmpty) {
            hit.position = Vector2.zero();
            return true;
          }
        }
      }
      hit.position = Vector2.zero();
    }

    return false;
  }

  /// if return `false` so the object will not collide with anything or block the passage.
  // bool onCollision(GameComponent component, bool active) {
  //   return true;
  // }

  // void setupCollision(CollisionConfig collisionConfig) {
  //   _collisionConfig = collisionConfig;
  // }

  // void enableCollision(bool enable) {
  //   _collisionConfig?.enable = enable;
  // }

  // void setCollisionOnlyVisibleScreen(bool onlyVisible) {
  //   _collisionConfig?.collisionOnlyVisibleScreen = onlyVisible;
  // }

  // List<ObjectCollision> isCollision({
  //   Vector2? displacement,
  //   bool stopSearchOnFirstCollision = true,
  // }) {
  //   if (!containCollision()) return [];

  //   return _verifyWorldCollision(
  //     displacement: displacement,
  //     stopSearchOnFirstCollision: stopSearchOnFirstCollision,
  //   );
  // }

  // bool checkCollision(ObjectCollision component, {Vector2? displacement}) {
  //   return _collisionConfig?.verifyCollision(
  //         component.collisionConfig,
  //         displacement: displacement,
  //       ) ??
  //       false;
  // }

  // bool containCollision() => _containCollision;

  // // Rect get rectCollision {
  // //   return _collisionConfig?.rect ?? Rect.zero;
  // // }

  // List<ObjectCollision> _verifyWorldCollision({
  //   Vector2? displacement,
  //   bool stopSearchOnFirstCollision = true,
  // }) {
  //   List<ObjectCollision> collisions = [];
  //   final compCollisions = _getWorldCollisions();

  //   for (final i in compCollisions) {
  //     bool occurred = _checkItemCollision(i, displacement: displacement);
  //     if (occurred) {
  //       collisions.add(i);
  //       if (stopSearchOnFirstCollision) {
  //         return collisions;
  //       }
  //     }
  //     for (final child in i.children) {
  //       if (child is ObjectCollision) {
  //         bool occurred = _checkItemCollision(
  //           child,
  //           displacement: displacement,
  //         );
  //         if (occurred) {
  //           collisions.add(child);
  //           if (stopSearchOnFirstCollision) {
  //             return collisions;
  //           }
  //         }
  //       }
  //     }
  //   }
  //   return collisions;
  // }

  // bool _checkItemCollision(ObjectCollision i, {Vector2? displacement}) {
  //   // if (i != this && checkCollision(i, displacement: displacement)) {
  //   //   return i.onCollision(this, false) && onCollision(i, true);
  //   // }
  //   return false;
  // }

  // Iterable<ObjectCollision> _getWorldCollisions() {
  //   if (hasGameRef) {
  //     return (_collisionConfig?.collisionOnlyVisibleScreen ?? true)
  //         ? gameRef.visibleCollisions()
  //         : gameRef.collisions();
  //   } else {
  //     return [];
  //   }
  // }

  // @override
  // void render(Canvas canvas) {
  //   super.render(canvas);
  //   if (gameRef.showCollisionArea) {
  //     renderCollision(
  //       canvas,
  //       gameRef.collisionAreaColor ?? Colors.lightGreen.withOpacity(0.5),
  //     );
  //   }
  // }

  // void renderCollision(Canvas canvas, Color color) {
  //   if (hasGameRef && containCollision()) {
  //     for (final element in _collisionConfig!.collisions) {
  //       element.render(canvas, color);
  //     }
  //   }
  // }

  // void _verifyIfContainCollision() {
  //   _containCollision = _collisionConfig?.collisions.isNotEmpty == true &&
  //       _collisionConfig?.enable == true;
  // }

  // @override
  // void onMount() {
  //   (gameRef as BonfireGame).addCollision(this);
  //   super.onMount();
  // }

  // @override
  // void onRemove() {
  //   (gameRef as BonfireGame).removeCollision(this);
  //   super.onRemove();
  // }
}
