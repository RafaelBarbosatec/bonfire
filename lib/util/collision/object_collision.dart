import 'dart:ui';

import 'package:bonfire/base/rpg_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/mixins/sensor.dart';
import 'package:flutter/material.dart';

mixin ObjectCollision on GameComponent {
  Iterable<Collision> collisions;

  void triggerSensors(Iterable<Rect> rectCollisions, RPGGame game) {
    final Iterable<Sensor> sensors = game
        .visibleSensors()
        .where(
          (decoration) => decoration is Sensor,
        )
        .cast();

    for (final sensor in sensors) {
      if (sensor.areaSensor.overlaps(rectCollisions.first)) {
        sensor.onContact(this);
      }
    }
  }

  bool isCollision({
    Rect displacement,
    bool onlyVisible = true,
    bool shouldTriggerSensors = true,
  }) {
    if (!containCollision()) return false;

    final rectCollisions = getRectCollisions(displacement ?? position);
    if (shouldTriggerSensors) triggerSensors(rectCollisions, gameRef);

    final collisionMap = (onlyVisible
            ? gameRef?.map?.getCollisionsRendered() ?? []
            : gameRef?.map?.getCollisions() ?? [])
        .firstWhere(
      (i) => i.detectCollision(rectCollisions),
      orElse: () => null,
    );
    if (collisionMap != null) return true;

    final collisionDecorations =
        (onlyVisible ? gameRef?.visibleDecorations() : gameRef?.decorations())
            .firstWhere(
      (i) => i.detectCollision(rectCollisions) && i != this,
      orElse: () => null,
    );
    if (collisionDecorations != null) return true;

    return false;
  }

  bool isCollisionTranslate(
    Rect position,
    double translateX,
    double translateY,
    RPGGame game, {
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

  bool containCollision() {
    return this.collisions != null && this.collisions.isNotEmpty;
  }

  bool detectCollision(Iterable<Rect> displacements) {
    if (!containCollision()) return false;
    final collision = displacements.firstWhere(
      (displacement) {
        return this.collisions.firstWhere(
              (element) {
                return element.getRect(this.position).overlaps(displacement);
              },
              orElse: () => null,
            ) !=
            null;
      },
      orElse: () => null,
    );

    return collision != null;
  }

  Rect get rectCollision => getRectCollision(position);
}
