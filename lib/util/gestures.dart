import 'dart:ui';

import 'package:flutter/gestures.dart';

mixin PointerDetector {
  void onPointerDown(PointerDownEvent event) {}
  void onPointerMove(PointerMoveEvent event) {}
  void onPointerUp(PointerUpEvent event) {}
  void onPointerCancel(PointerCancelEvent event) {}
}

mixin TapGesture {
  bool enableTab = true;
  void onTap() {}
  void onTapDown(int pointer) {}
  void onTapUp(int pointer, Offset position) {}
  void onTapCancel(int pointer) {}
}

mixin DragGesture {
  bool enableDrag = true;
  bool enableDragWithCollision = false; // TODO implementation
  void startDrag() {}
  void moveDrag(Offset position) {}
  void endDrag(Offset position) {}
}
