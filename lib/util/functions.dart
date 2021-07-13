import 'dart:math';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';

void renderSpriteByRadAngle(
  Canvas canvas,
  double radAngle,
  Vector2Rect position,
  Sprite sprite,
) {
  canvas.save();
  canvas.translate(position.center.dx, position.center.dy);
  canvas.rotate(radAngle == 0.0 ? 0.0 : radAngle + (pi / 2));
  canvas.translate(-position.center.dx, -position.center.dy);
  sprite.renderFromVector2Rect(canvas, position);
  canvas.restore();
}

/// Gets player position used how base in calculations
Vector2Rect getRectAndCollision(GameComponent? comp) {
  return ((comp?.isObjectCollision() ?? false)
          ? (comp as ObjectCollision).rectCollision
          : comp?.position) ??
      Vector2Rect.zero();
}
