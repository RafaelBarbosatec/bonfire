import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/movement_v2.dart';
import 'package:flutter/material.dart';

/// Mixin responsible for adding collision
mixin BlockMovementCollision on GameComponent {
  void onStopMovement(GameComponent other) {}

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (this is MovementV2) {
      MovementV2 comp = this as MovementV2;
      position += comp.lastDisplacement * -1;
      onStopMovement(other as GameComponent);
      comp.stop();
    }
    super.onCollision(intersectionPoints, other);
  }

  bool isCollision({Vector2? displacement}) {
    return false;
  }

  Rect get rectCollision {
    return Rect.zero;
  }

  bool containCollision() {
    return false;
  }
}
