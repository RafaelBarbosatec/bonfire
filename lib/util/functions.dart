import 'dart:math';

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

E? firstWhere<E>(
  Iterable<E> list,
  bool test(E element),
) {
  for (E element in list) {
    if (test(element)) return element;
  }
  return null;
}
