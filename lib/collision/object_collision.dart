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

  List<ObjectCollision> isCollision({
    Vector2? displacement,
    bool stopSearchOnFirstCollision = true,
  }) {
    if (!containCollision()) return [];

    return _verifyWorldCollision(
      displacement: displacement,
      stopSearchOnFirstCollision: stopSearchOnFirstCollision,
    );
  }

  bool checkCollision(ObjectCollision component, {Vector2? displacement}) {
    return _collisionConfig?.verifyCollision(
          component.collisionConfig,
          displacement: displacement,
        ) ??
        false;
  }

  bool containCollision() => _containCollision;

  Vector2Rect get rectCollision {
    if (!containCollision()) return Vector2Rect.zero();
    return _collisionConfig!.vector2rect;
  }

  List<ObjectCollision> _verifyWorldCollision({
    Vector2? displacement,
    bool stopSearchOnFirstCollision = true,
  }) {
    List<ObjectCollision> collisions = [];
    final compCollisions = _getWorldCollisions();

    for (final i in compCollisions) {
      if (i != this && checkCollision(i, displacement: displacement)) {
        onCollision(i, true);
        i.onCollision(this, false);
        collisions.add(i);
        if (stopSearchOnFirstCollision) {
          return collisions;
        }
      }
    }
    return collisions;
  }

  Iterable<ObjectCollision> _getWorldCollisions() {
    return (_collisionConfig?.collisionOnlyVisibleScreen ?? true)
        ? gameRef.visibleCollisions()
        : gameRef.collisions();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (hasGameRef) {
      if ((gameRef as BonfireGame).showCollisionArea == true) {
        _drawCollision(
          canvas,
          (gameRef as BonfireGame).collisionAreaColor ??
              Colors.lightGreen.withOpacity(0.5),
        );
      }
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
