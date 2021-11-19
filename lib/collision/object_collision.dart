import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/material.dart';

/// Mixin responsible for adding collision
mixin ObjectCollision on GameComponent {
  CollisionConfig? _collisionConfig;

  CollisionConfig? get collisionConfig => _collisionConfig;

  bool _containCollision = false;

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
    Vector2? displacement,
    bool shouldTriggerSensors = true,
  }) {
    if (!containCollision()) return false;

    if (_verifyComponentCollision(position: displacement)) {
      return true;
    }

    return false;
  }

  Vector2Rect getRectCollision() {
    if (!containCollision()) return Vector2Rect.zero();
    return _collisionConfig!.vector2rect;
  }

  bool containCollision() => _containCollision;

  Vector2Rect get rectCollision => getRectCollision();

  bool _verifyComponentCollision({Vector2? position}) {
    final compCollisions =
        ((_collisionConfig?.collisionOnlyVisibleScreen ?? true)
            ? gameRef.visibleCollisions()
            : gameRef.collisions());

    for (final i in compCollisions) {
      if (i != this &&
          (_collisionConfig?.verifyCollision(i.collisionConfig,
                  position: position) ??
              false)) {
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
    if ((gameRef as BonfireGame).showCollisionArea == true) {
      _drawCollision(
        canvas,
        (gameRef as BonfireGame).collisionAreaColor ??
            Colors.lightGreen.withOpacity(0.5),
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
    _containCollision = _collisionConfig?.collisions != null &&
        _collisionConfig?.collisions.isNotEmpty == true &&
        _collisionConfig?.enable == true;
    super.update(dt);
  }

  void updatePosition(Vector2Rect position) {
    _collisionConfig?.updatePosition(position);
  }
}
