import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision.dart';
import 'package:bonfire/util/mixins/sensor.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/material.dart';

class CollisionConfig {
  /// Representing the collision area
  final Iterable<CollisionArea> collisions;

  bool collisionOnlyVisibleScreen;
  bool enable;

  CollisionConfig({
    required this.collisions,
    this.collisionOnlyVisibleScreen = true,
    this.enable = true,
  });
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

  void triggerSensors(Iterable<Vector2Rect> rectCollisions) {
    gameRef.let((ref) {
      final Iterable<Sensor> sensors = ref
          .visibleSensors()
          .where((decoration) => decoration is Sensor)
          .cast();

      sensors.forEach((sensor) {
        if (sensor.areaSensor.overlaps(rectCollisions.first))
          sensor.onContact(this);
      });
    });
  }

  bool isCollision({
    Vector2Rect? displacement,
    bool shouldTriggerSensors = true,
  }) {
    if (!containCollision()) return false;

    final rectCollisions = getRectCollisions(displacement ?? position);

    if (shouldTriggerSensors) triggerSensors(rectCollisions);

    if (_containsCollisionWithMap(rectCollisions)) return true;

    if (_containsCollision(rectCollisions)) return true;

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

  Iterable<Vector2Rect> getRectCollisions(Vector2Rect displacement) {
    if (!containCollision()) return [];
    return _collisionConfig!.collisions
        .map<Vector2Rect>((e) => e.getVectorCollision(displacement));
  }

  Vector2Rect getRectCollision(Vector2Rect displacement) {
    if (!containCollision()) return Vector2Rect.zero();
    return _collisionConfig!.collisions
        .map<Vector2Rect>((e) => e.getVectorCollision(displacement))
        .first;
  }

  void _drawCollision(Canvas canvas, Color? color) {
    if (!containCollision()) return;
    _collisionConfig!.collisions.forEach((element) {
      canvas.drawRect(
        element.getVectorCollision(position).rect,
        Paint()..color = color ?? Colors.lightGreenAccent.withOpacity(0.5),
      );
    });
  }

  bool detectCollision(Iterable<Vector2Rect> displacements) {
    if (!containCollision()) return false;
    final collision = displacements.where((displacement) {
      final c = _collisionConfig!.collisions.where(
        (element) =>
            element.getVectorCollision(this.position).overlaps(displacement),
      );
      return c.isNotEmpty;
    });

    return collision.isNotEmpty;
  }

  bool containCollision() =>
      _collisionConfig?.collisions != null &&
      _collisionConfig?.collisions.isNotEmpty == true &&
      _collisionConfig?.enable == true;

  Vector2Rect get rectCollision => getRectCollision(position);

  bool _containsCollisionWithMap(Iterable<Vector2Rect> rectCollisions) {
    final tiledCollisions =
        ((_collisionConfig?.collisionOnlyVisibleScreen ?? false)
            ? gameRef.map.getCollisionsRendered()
            : gameRef.map.getCollisions());
    final collisionMap = tiledCollisions.where(
      (i) =>
          (i is ObjectCollision) &&
          (i as ObjectCollision).detectCollision(rectCollisions),
    );
    return collisionMap.isNotEmpty;
  }

  bool _containsCollision(Iterable<Vector2Rect> rectCollisions) {
    final collisions = ((_collisionConfig?.collisionOnlyVisibleScreen ?? true)
            ? gameRef.visibleCollisions()
            : gameRef.collisions())
        .where(
      (i) => i.detectCollision(rectCollisions) && i != this,
    );
    return collisions.isNotEmpty;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (gameRef.showCollisionArea == true) {
      _drawCollision(canvas, gameRef.collisionAreaColor);
    }
  }

  bool notVisibleAndCollisionOnlyScreen() {
    return (_collisionConfig?.collisionOnlyVisibleScreen ?? true) &&
        !isVisibleInCamera();
  }
}
