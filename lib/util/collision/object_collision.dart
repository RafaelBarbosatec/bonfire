import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/mixins/sensor.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/material.dart';

class CollisionConfig {
  /// Used to enable or disable collision with enemy
  final bool collisionWithEnemy;

  /// Used to enable or disable collision with player
  final bool collisionWithPlayer;

  bool collisionOnlyVisibleScreen;

  /// Representing the collision area
  final Iterable<CollisionArea> collisions;

  CollisionConfig({
    @required this.collisions,
    this.collisionWithEnemy = false,
    this.collisionWithPlayer = false,
    this.collisionOnlyVisibleScreen = true,
  });
}

mixin ObjectCollision on GameComponent {
  CollisionConfig _collisionConfig;

  void setupCollision(CollisionConfig collisionConfig) {
    _collisionConfig = collisionConfig;
  }

  void removeCollision() {
    _collisionConfig = null;
  }

  void setCollisionOnlyVisibleScreen(bool onlyVisible) {
    _collisionConfig.collisionOnlyVisibleScreen = onlyVisible;
  }

  void triggerSensors(Iterable<Vector2Rect> rectCollisions) {
    final Iterable<Sensor> sensors = gameRef
        .visibleSensors()
        .where((decoration) => decoration is Sensor)
        .cast();

    sensors.forEach((sensor) {
      if (sensor.areaSensor.overlaps(rectCollisions.first))
        sensor.onContact(this);
    });
  }

  bool isCollision({
    Rect displacement,
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
    Rect position,
    double translateX,
    double translateY,
  ) {
    var moveToCurrent = position.translate(translateX, translateY);
    return isCollision(displacement: moveToCurrent);
  }

  Iterable<Vector2Rect> getRectCollisions(Vector2Rect displacement) {
    if (!containCollision()) return [];
    return _collisionConfig?.collisions
        ?.map<Vector2Rect>((e) => e.getVectorCollision(displacement));
  }

  Vector2Rect getRectCollision(Vector2Rect displacement) {
    if (!containCollision()) return Vector2Rect.zero();
    return _collisionConfig?.collisions
        ?.map<Vector2Rect>((e) => e.getVectorCollision(displacement))
        ?.first;
  }

  void drawCollision(Canvas canvas, Color color) {
    if (!containCollision()) return;
    _collisionConfig?.collisions?.forEach((element) {
      canvas.drawRect(
        element.getVectorCollision(position).rect,
        Paint()..color = color ?? Colors.lightGreenAccent.withOpacity(0.5),
      );
    });
  }

  bool detectCollision(Iterable<Vector2Rect> displacements) {
    if (!containCollision()) return false;
    final collision = displacements.firstWhere(
      (displacement) {
        final c = _collisionConfig?.collisions?.firstWhere(
          (element) =>
              element.getVectorCollision(this.position).overlaps(displacement),
          orElse: () => null,
        );
        return c != null;
      },
      orElse: () => null,
    );

    return collision != null;
  }

  bool containCollision() =>
      _collisionConfig?.collisions != null &&
      _collisionConfig?.collisions?.isNotEmpty == true;

  Vector2Rect get rectCollision => getRectCollision(position);

  bool _containsCollisionWithMap(Iterable<Vector2Rect> rectCollisions) {
    final tiledCollisions =
        ((_collisionConfig?.collisionOnlyVisibleScreen ?? false)
            ? gameRef?.map?.getCollisionsRendered() ?? []
            : gameRef?.map?.getCollisions() ?? []);
    final collisionMap = tiledCollisions.firstWhere(
      (i) =>
          (i is ObjectCollision) &&
          (i as ObjectCollision).detectCollision(rectCollisions),
      orElse: () => null,
    );
    return collisionMap != null;
  }

  bool _containsCollision(Iterable<Vector2Rect> rectCollisions) {
    final collisions = ((_collisionConfig?.collisionOnlyVisibleScreen ?? true)
            ? gameRef?.visibleCollisions()
            : gameRef?.collisions())
        ?.firstWhere(
      (i) {
        return i.detectCollision(rectCollisions) && i != this;
      },
      orElse: () => null,
    );
    return collisions != null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (gameRef != null && gameRef.showCollisionArea) {
      drawCollision(canvas, gameRef.collisionAreaColor);
    }
  }

  bool notVisibleAndCollisionOnlyScreen() {
    return (_collisionConfig?.collisionOnlyVisibleScreen ?? true) &&
        !isVisibleInCamera();
  }
}
