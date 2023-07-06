import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flame/palette.dart';

extension ShapeHitboxExt on ShapeHitbox {
  void customRender(Canvas canvas, Paint paint) {
    this.paint = paint;
    renderShape = true;
    render(canvas);
    renderShape = false;
    paint = BasicPalette.white.paint();
  }
}
