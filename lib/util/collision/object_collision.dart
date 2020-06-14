import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:flutter/material.dart';

mixin ObjectCollision {
  Collision collision;

  void triggerSensors(Rect displacement, RPGGame game) {
    Rect rectCollision = getRectCollision(displacement);

    final sensors = game.visibleDecorations().where(
          (decoration) => decoration.isSensor,
        );

    sensors.forEach((decoration) {
      if (decoration.rectCollision.overlaps(rectCollision))
        decoration.onContact(this);
    });
  }

  bool isCollision(
    Rect displacement,
    RPGGame game, {
    bool onlyVisible = true,
    bool shouldTriggerSensors = true,
  }) {
    if (this.collision == null) return false;

    Rect rectCollision = getRectCollision(displacement);
    if (shouldTriggerSensors) triggerSensors(displacement, game);

    final collisions = (onlyVisible
            ? game.map?.getCollisionsRendered() ?? []
            : game.map?.getCollisions() ?? [])
        .where((i) => i.containCollision(rectCollision));
    if (collisions.isNotEmpty) return true;

    final collisionsDecorations =
        (onlyVisible ? game.visibleDecorations() : game.decorations()).where(
            (i) =>
                !i.isSensor &&
                i.collision != null &&
                i.rectCollision.overlaps(rectCollision));

    if (collisionsDecorations.isNotEmpty) return true;

    return false;
  }

  bool isCollisionTranslate(
      Rect position, double translateX, double translateY, RPGGame game,
      {bool onlyVisible = true}) {
    var moveToCurrent = position.translate(translateX, translateY);
    return isCollision(moveToCurrent, game, onlyVisible: onlyVisible);
  }

  Rect getRectCollision(Rect displacement) {
    if (collision == null) return displacement;
    return collision.calculateRectCollision(displacement);
  }

  void drawCollision(Canvas canvas, Rect currentPosition, Color color) {
    if (collision == null) return;
    canvas.drawRect(
      getRectCollision(currentPosition),
      new Paint()..color = color ?? Colors.lightGreenAccent.withOpacity(0.5),
    );
  }
}
