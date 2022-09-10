import 'dart:math';

import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';

void renderSpriteByRadAngle(
  Canvas canvas,
  double radAngle,
  Rect position,
  Sprite sprite, {
  Paint? overridePaint,
}) {
  canvas.save();
  canvas.translate(position.center.dx, position.center.dy);
  canvas.rotate(radAngle == 0.0 ? 0.0 : radAngle + (pi / 2));
  canvas.translate(-position.center.dx, -position.center.dy);
  sprite.render(
    canvas,
    position: position.positionVector2,
    size: position.sizeVector2,
    overridePaint: overridePaint,
  );
  canvas.restore();
}

E? firstWhere<E>(
  Iterable<E> list,
  bool Function(E element) test,
) {
  for (E element in list) {
    if (test(element)) return element;
  }
  return null;
}
