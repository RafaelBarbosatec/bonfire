import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flame/palette.dart';

extension ShapeHitboxExt on ShapeHitbox {
  void customRender(Canvas canvas, Color color) {
    paint = Paint()..color = color;
    renderShape = true;
    render(canvas);
    renderShape = false;
    paint = BasicPalette.white.paint();
  }
}
