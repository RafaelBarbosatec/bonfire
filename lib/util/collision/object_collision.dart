import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/mixins/sensor.dart';
import 'package:flutter/material.dart';

mixin ObjectCollision on GameComponent {
  /// Used to enable or disable collision with enemy
  bool collisionWithEnemy = false;

  /// Used to enable or disable collision with player
  bool collisionWithPlayer = false;

  /// Representing the collision area
  Iterable<Collision> collisions;

  void triggerSensors(Iterable<Rect> rectCollisions) {
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
    bool onlyVisible = true,
    bool shouldTriggerSensors = true,
  }) {
    if (!containCollision()) return false;

    final rectCollisions = getRectCollisions(displacement ?? position);

    if (shouldTriggerSensors) triggerSensors(rectCollisions);

    if (_containsCollisionWithMap(rectCollisions, onlyVisible)) return true;

    if (_containsCollisionWithDecoration(rectCollisions, onlyVisible))
      return true;

    if (_containsCollisionWithEnemies(rectCollisions, onlyVisible)) return true;

    if (_containsCollisionWithPlayer(rectCollisions, onlyVisible)) return true;

    return false;
  }

  bool isCollisionPositionTranslate(
    Rect position,
    double translateX,
    double translateY, {
    bool onlyVisible = true,
  }) {
    var moveToCurrent = position.translate(translateX, translateY);
    return isCollision(displacement: moveToCurrent, onlyVisible: onlyVisible);
  }

  Iterable<Rect> getRectCollisions(Rect displacement) {
    if (!containCollision()) return [];
    return collisions.map<Rect>((e) => e.getRect(displacement));
  }

  Rect getRectCollision(Rect displacement) {
    if (!containCollision()) return Rect.zero;
    return collisions.map<Rect>((e) => e.getRect(displacement)).first;
  }

  void drawCollision(Canvas canvas, Rect currentPosition, Color color) {
    if (!containCollision()) return;
    collisions.forEach((element) {
      canvas.drawRect(
        element.getRect(currentPosition),
        Paint()..color = color ?? Colors.lightGreenAccent.withOpacity(0.5),
      );
    });
  }

  bool detectCollision(Iterable<Rect> displacements) {
    if (!containCollision()) return false;
    final collision = displacements.firstWhere(
      (displacement) {
        final c = this.collisions.firstWhere(
              (element) =>
                  element.getRect(this.position).overlaps(displacement),
              orElse: () => null,
            );
        return c != null;
      },
      orElse: () => null,
    );

    return collision != null;
  }

  bool containCollision() =>
      this.collisions != null && this.collisions.isNotEmpty;

  Rect get rectCollision => getRectCollision(position);

  bool _containsCollisionWithMap(
      Iterable<Rect> rectCollisions, bool onlyVisible) {
    final tiledCollisions = (onlyVisible
        ? gameRef?.map?.getCollisionsRendered() ?? []
        : gameRef?.map?.getCollisions() ?? []);
    final collisionMap = tiledCollisions.firstWhere(
      (i) => i.detectCollision(rectCollisions),
      orElse: () => null,
    );
    return collisionMap != null;
  }

  bool _containsCollisionWithDecoration(
      Iterable<Rect> rectCollisions, bool onlyVisible) {
    final collisionDecorations =
        (onlyVisible ? gameRef?.visibleDecorations() : gameRef?.decorations())
            .firstWhere(
      (i) => i.detectCollision(rectCollisions) && i != this,
      orElse: () => null,
    );
    return collisionDecorations != null;
  }

  bool _containsCollisionWithEnemies(
      Iterable<Rect> rectCollisions, bool onlyVisible) {
    if (collisionWithEnemy) {
      final collisionEnemy =
          (onlyVisible ? gameRef?.visibleEnemies() : gameRef?.enemies())
              ?.firstWhere(
        (i) {
          return i.detectCollision(rectCollisions) && i != this;
        },
        orElse: () => null,
      );
      return collisionEnemy != null;
    } else {
      return false;
    }
  }

  bool _containsCollisionWithPlayer(
      Iterable<Rect> rectCollisions, bool onlyVisible) {
    if (collisionWithPlayer) {
      return gameRef?.player?.detectCollision(rectCollisions) == true;
    } else {
      return false;
    }
  }
}
