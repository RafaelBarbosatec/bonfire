import 'dart:math';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';

import 'direction.dart';

const PI_180 = (180 / pi);

void renderSpriteByRadAngle(
  Canvas canvas,
  double radAngle,
  Rect position,
  Sprite sprite, {
  double opacity = 1.0,
}) {
  canvas.save();
  canvas.translate(position.center.dx, position.center.dy);
  canvas.rotate(radAngle == 0.0 ? 0.0 : radAngle + (pi / 2));
  canvas.translate(-position.center.dx, -position.center.dy);
  sprite.renderWithOpacity(
    canvas,
    position.positionVector2,
    position.sizeVector2,
    opacity: opacity,
  );
  canvas.restore();
}

/// Gets player position used how base in calculations
Rect getRectAndCollision(GameComponent? comp) {
  return ((comp?.isObjectCollision() ?? false)
          ? (comp as ObjectCollision).rectCollision
          : comp?.toRect()) ??
      Rect.zero;
}

E? firstWhere<E>(
  Iterable<E> list,
  bool test(E element),
) {
  for (E element in list) {
    if (test(element)) return element;
  }
  return null;
}

Direction getDirectionByAngle(double angle) {
  double degrees = angle * 180 / pi;

  if (degrees > -22.5 && degrees <= 22.5) {
    return Direction.right;
  }

  if (degrees > 22.5 && degrees <= 67.5) {
    return Direction.downRight;
  }

  if (degrees > 67.5 && degrees <= 112.5) {
    return Direction.down;
  }

  if (degrees > 112.5 && degrees <= 157.5) {
    return Direction.downLeft;
  }

  if ((degrees > 157.5 && degrees <= 180) ||
      (degrees >= -180 && degrees <= -157.5)) {
    return Direction.left;
  }

  if (degrees > -157.5 && degrees <= -112.5) {
    return Direction.upLeft;
  }

  if (degrees > -112.5 && degrees <= -67.5) {
    return Direction.up;
  }

  if (degrees > -67.5 && degrees <= -22.5) {
    return Direction.upRight;
  }
  return Direction.left;
}

double getAngleByDirectional(Direction direction) {
  switch (direction) {
    case Direction.left:
      return 180 / PI_180;
    case Direction.right:
      // we can't use 0 here because then no movement happens
      // we're just going as close to 0.0 without being exactly 0.0
      // if you have a better idea. Please be my guest
      return 0.0000001 / PI_180;
    case Direction.up:
      return -90 / PI_180;
    case Direction.down:
      return 90 / PI_180;
    case Direction.upLeft:
      return -135 / PI_180;
    case Direction.upRight:
      return -45 / PI_180;
    case Direction.downLeft:
      return 135 / PI_180;
    case Direction.downRight:
      return 45 / PI_180;
    default:
      return 0;
  }
}
