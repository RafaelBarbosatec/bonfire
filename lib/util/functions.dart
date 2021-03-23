import 'dart:math';

import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';

void renderSpriteByRadAngle(
  Canvas canvas,
  double radAngle,
  Vector2Rect rect,
  Sprite sprite,
) {
  canvas.save();
  canvas.translate(rect.center.dx, rect.center.dy);
  canvas.rotate(radAngle == 0.0 ? 0.0 : radAngle + (pi / 2));
  canvas.translate(-rect.center.dx, -rect.center.dy);
  sprite.render(canvas, position: rect.position, size: rect.size);
  canvas.restore();
}
