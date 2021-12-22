import 'dart:math';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';

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
