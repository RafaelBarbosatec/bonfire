import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/util/extensions.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/material.dart';

mixin ObjectCollision on GameComponent {
  CollisionConfig? _collisionConfig;

  CollisionConfig? get collisionConfig => _collisionConfig;

  void onCollision(GameComponent component, bool active) {}

  void setupCollision(CollisionConfig collisionConfig) {
    _collisionConfig = collisionConfig;
  }

  void enableCollision(bool enable) {
    _collisionConfig?.enable = enable;
  }

  void setCollisionOnlyVisibleScreen(bool onlyVisible) {
    _collisionConfig?.collisionOnlyVisibleScreen = onlyVisible;
  }

  bool isCollision({
    Vector2Rect? displacement,
    bool shouldTriggerSensors = true,
  }) {
    if (!containCollision()) return false;

    if (displacement != null) {
      updatePosition(displacement);
    }

    if (_verifyComponentCollision()) return true;

    return false;
  }

  Vector2Rect getRectCollision() {
    if (!containCollision()) return Vector2Rect.zero();
    return _collisionConfig!.rect.toVector2Rect();
  }

  bool containCollision() =>
      _collisionConfig?.collisions != null &&
      _collisionConfig?.collisions.isNotEmpty == true &&
      _collisionConfig?.enable == true;

  Vector2Rect get rectCollision => getRectCollision();

  bool _verifyComponentCollision() {
    final compCollisions =
        ((_collisionConfig?.collisionOnlyVisibleScreen ?? true)
            ? gameRef.visibleCollisions()
            : gameRef.collisions());

    for (final i in compCollisions) {
      if (i != this &&
          (_collisionConfig?.verifyCollision(i.collisionConfig) ?? false)) {
        onCollision(i, true);
        i.onCollision(this, false);
        return true;
      }
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (gameRef.showCollisionArea == true) {
      _drawCollision(
        canvas,
        gameRef.collisionAreaColor ?? Colors.lightGreen.withOpacity(0.5),
      );
    }
  }

  void _drawCollision(Canvas canvas, Color color) {
    if (!containCollision()) return;

    for (final element in _collisionConfig!.collisions) {
      element.render(canvas, color);
    }
  }

  @override
  void update(double dt) {
    updatePosition(this.position);
    super.update(dt);
  }

  void updatePosition(Vector2Rect position) {
    _collisionConfig?.updatePosition(position);
  }
}
