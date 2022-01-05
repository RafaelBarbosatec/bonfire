import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// Mixin responsible for adding collision
mixin ObjectCollision on GameComponent {
  CollisionConfig? _collisionConfig;

  CollisionConfig? get collisionConfig => _collisionConfig;

  bool _containCollision = false;

  bool onCollision(GameComponent component, bool active) {
    return true;
  }

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

  Rect get rectCollision {
    if (!containCollision()) return Rect.zero;
    return _collisionConfig!.rect;
  }

  List<ObjectCollision> _verifyWorldCollision({
    Vector2? displacement,
    bool stopSearchOnFirstCollision = true,
  }) {
    List<ObjectCollision> collisions = [];
    final compCollisions = _getWorldCollisions();

    for (final i in compCollisions) {
      bool occurred = _checkItemCollision(i, displacement: displacement);
      if (occurred) {
        collisions.add(i);
        if (stopSearchOnFirstCollision) {
          return collisions;
        }
      }
      for (final child in i.children) {
        if (child is ObjectCollision) {
          bool occurred = _checkItemCollision(
            child,
            displacement: displacement,
          );
          if (occurred) {
            collisions.add(child);
            if (stopSearchOnFirstCollision) {
              return collisions;
            }
          }
        }
      }
    }
    return collisions;
  }

  bool _checkItemCollision(ObjectCollision i, {Vector2? displacement}) {
    if (i != this && checkCollision(i, displacement: displacement)) {
      onCollision(i, true);
      return i.onCollision(this, false);
    }
    return false;
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
      if (gameRef.showCollisionArea == true) {
        _drawCollision(
          canvas,
          gameRef.collisionAreaColor ?? Colors.lightGreen.withOpacity(0.5),
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

  void updatePosition(Vector2 position) {
    _collisionConfig?.updatePosition(position);
  }
}
