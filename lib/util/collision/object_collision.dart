import 'dart:ui';

import 'package:bonfire/base/rpg_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/mixins/sensor.dart';
import 'package:flutter/material.dart';

mixin ObjectCollision {
  Iterable<Collision> collisions;

  void triggerSensors(Iterable<Rect> rectCollisions, RPGGame game) {
    final Iterable<Sensor> sensors = game
        .visibleSensors()
        .where(
          (decoration) => decoration is Sensor,
        )
        .cast();

    sensors.forEach((sensor) {
      if (sensor.areaSensor.overlaps(rectCollisions.first)) {
        sensor.onContact(this);
      }
    });
  }

  bool isCollision(
    Rect displacement,
    RPGGame game, {
    bool onlyVisible = true,
    bool shouldTriggerSensors = true,
  }) {
    if (!containCollision()) return false;

    final rectCollisions = getRectCollisions(displacement);
    if (shouldTriggerSensors) triggerSensors(rectCollisions, game);

    final collisions = (onlyVisible
            ? game.map?.getCollisionsRendered() ?? []
            : game.map?.getCollisions() ?? [])
        .where((i) => i.detectCollision(rectCollisions));
    if (collisions.isNotEmpty) return true;

    final collisionsDecorations =
        (onlyVisible ? game.visibleDecorations() : game.decorations())
            .where((i) => i.detectCollision(rectCollisions));

    if (collisionsDecorations.isNotEmpty) return true;

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
    return isCollision(moveToCurrent, game, onlyVisible: onlyVisible);
  }

  Iterable<Rect> getRectCollisions(Rect displacement) {
    if (!containCollision()) return [];
    return collisions.map<Rect>((e) => e.calculateRectCollision(displacement));
  }

  Rect getRectCollision(Rect displacement) {
    if (!containCollision()) return Rect.zero;
    return collisions
        .map<Rect>((e) => e.calculateRectCollision(displacement))
        .first;
  }

  void drawCollision(Canvas canvas, Rect currentPosition, Color color) {
    if (!containCollision()) return;
    collisions.forEach((element) {
      canvas.drawRect(
        element.calculateRectCollision(currentPosition),
        Paint()..color = color ?? Colors.lightGreenAccent.withOpacity(0.5),
      );
    });
  }

  bool containCollision() {
    return this.collisions != null && this.collisions.isNotEmpty;
  }

  bool detectCollision(Iterable<Rect> displacements) {
    if (!containCollision() || !(this is GameComponent)) return false;
    return displacements
        .where((displacement) => this
            .collisions
            .where((element) => element
                .calculateRectCollision((this as GameComponent).position)
                .overlaps(displacement))
            .isNotEmpty)
        .isNotEmpty;
  }
}
