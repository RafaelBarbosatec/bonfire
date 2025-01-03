import 'dart:math';

import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';

// Could be helpful to render some sprite rotanting using angle.
void renderSpriteByRadAngle(
  Canvas canvas,
  double radAngle,
  Rect rect,
  Sprite sprite, {
  Paint? overridePaint,
}) {
  canvas.save();
  canvas.translate(rect.center.dx, rect.center.dy);
  canvas.rotate(radAngle == 0.0 ? 0.0 : radAngle + (pi / 2));
  canvas.translate(-rect.center.dx, -rect.center.dy);
  sprite.render(
    canvas,
    position: rect.positionVector2,
    size: rect.sizeVector2,
    overridePaint: overridePaint,
  );
  canvas.restore();
}

E? firstWhere<E>(
  Iterable<E> list,
  bool Function(E element) test,
) {
  for (final element in list) {
    if (test(element)) {
      return element;
    }
  }
  return null;
}

// Help you to calculate zoom by max tiles can be visible
double getZoomFromMaxVisibleTile(
  BuildContext context,
  double tileSize,
  int maxTile, {
  Orientation? orientation,
}) {
  final screenSize = MediaQuery.of(context).size;
  if (screenSize == Size.zero || screenSize == Size.infinite) {
    return 1;
  }
  var maxSize = 0.0;
  switch (orientation) {
    case Orientation.portrait:
      maxSize = screenSize.height;
      break;
    case Orientation.landscape:
      maxSize = screenSize.width;
      break;
    default:
      maxSize = max(screenSize.width, screenSize.height);
  }
  return maxSize / (tileSize * maxTile);
}
