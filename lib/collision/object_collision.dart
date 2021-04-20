import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/util/extensions.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/material.dart';

class CollisionConfig {
  /// Representing the collision area
  final Iterable<CollisionArea> collisions;

  bool collisionOnlyVisibleScreen;
  bool enable;

  Rect _rect = Rect.zero;

  Vector2Rect? _lastPosition;

  CollisionConfig({
    required this.collisions,
    this.collisionOnlyVisibleScreen = true,
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
        _rect.expandToInclude(element.rect);
      }
      _lastPosition = position;
    }
  }
}

mixin ObjectCollision on GameComponent {
  CollisionConfig? _collisionConfig;

  CollisionConfig? get collisionConfig => _collisionConfig;

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

    if (_verifyMapCollision()) return true;

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

  bool _verifyMapCollision() {
    final Iterable<ObjectCollision> tiledCollisions =
        ((_collisionConfig?.collisionOnlyVisibleScreen ?? false)
            ? gameRef.map.getCollisionsRendered()
            : gameRef.map.getCollisions());

    for (final i in tiledCollisions) {
      if (_collisionConfig?.verifyCollision(i.collisionConfig) ?? false) {
        return true;
      }
    }
    return false;
  }

  bool _verifyComponentCollision() {
    final compCollisions =
        ((_collisionConfig?.collisionOnlyVisibleScreen ?? true)
            ? gameRef.visibleCollisions()
            : gameRef.collisions());

    for (final i in compCollisions) {
      if (i != this &&
          (_collisionConfig?.verifyCollision(i.collisionConfig) ?? false)) {
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

  bool notVisibleAndCollisionOnlyScreen() {
    return (_collisionConfig?.collisionOnlyVisibleScreen ?? true) &&
        !isVisibleInCamera();
  }

  void updatePosition(Vector2Rect position) {
    _collisionConfig?.updatePosition(position);
  }
}
