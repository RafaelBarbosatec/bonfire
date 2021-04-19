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
      return collisions.where((element1) {
        return other.collisions.where((element2) {
          return element1.verifyCollision(element2);
        }).isNotEmpty;
      }).isNotEmpty;
    } else {
      return false;
    }
  }

  void updatePosition(Vector2Rect position) {
    if (collisions.isNotEmpty && position != _lastPosition) {
      collisions.first.updatePosition(position);
      _rect = collisions.first.rect;
      collisions.forEach((element) {
        element.updatePosition(position);
        _rect.expandToInclude(element.rect);
      });
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

    if (_containsCollisionWithMap()) return true;

    if (_containsCollision()) return true;

    return false;
  }

  bool isCollisionPositionTranslate(
    Vector2Rect position,
    double translateX,
    double translateY,
  ) {
    var moveToCurrent = position.translate(translateX, translateY);
    return isCollision(displacement: moveToCurrent);
  }

  Vector2Rect getRectCollision(Vector2Rect displacement) {
    if (!containCollision()) return Vector2Rect.zero();
    return _collisionConfig!.rect.toVector2Rect();
  }

  void _drawCollision(Canvas canvas, Color color) {
    if (!containCollision()) return;
    _collisionConfig!.collisions.forEach((element) {
      element.render(canvas, color);
    });
  }

  bool containCollision() =>
      _collisionConfig?.collisions != null &&
      _collisionConfig?.collisions.isNotEmpty == true &&
      _collisionConfig?.enable == true;

  Vector2Rect get rectCollision => getRectCollision(position);

  bool _containsCollisionWithMap() {
    final Iterable<ObjectCollision> tiledCollisions =
        ((_collisionConfig?.collisionOnlyVisibleScreen ?? false)
            ? gameRef.map.getCollisionsRendered()
            : gameRef.map.getCollisions());

    final collisionMap = tiledCollisions.where(
      (i) => _collisionConfig?.verifyCollision(i.collisionConfig) ?? false,
    );
    return collisionMap.isNotEmpty;
  }

  bool _containsCollision() {
    final compCollisions =
        ((_collisionConfig?.collisionOnlyVisibleScreen ?? true)
            ? gameRef.visibleCollisions()
            : gameRef.collisions());

    final collisions = compCollisions.where(
      (i) =>
          i != this &&
          (_collisionConfig?.verifyCollision(i.collisionConfig) ?? false),
    );
    return collisions.isNotEmpty;
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
