import 'package:bonfire/util/gestures/drag_gesture.dart';
import 'package:bonfire/util/gestures/mouse_hover_gesture.dart';
import 'package:bonfire/util/gestures/tap_gesture.dart';
import 'package:flutter/gestures.dart';

mixin PointerDetector {
  void onPointerDown(PointerDownEvent event) {}
  void onPointerMove(PointerMoveEvent event) {}
  void onPointerUp(PointerUpEvent event) {}
  void onPointerCancel(PointerCancelEvent event) {}
  void onPointerHover(PointerHoverEvent event) {}
}

abstract class PointerDetectorHandler {
  void handlerPointerDown(PointerDownEvent event) {}
  void handlerPointerMove(PointerMoveEvent event) {}
  void handlerPointerUp(PointerUpEvent event) {}
  void handlerPointerCancel(PointerCancelEvent event) {}
  void handlerPointerHover(PointerHoverEvent event) {}

  bool hasGesture() {
    if (this is DragGesture && (this as DragGesture).enableDrag) return true;
    if (this is TapGesture && (this as TapGesture).enableTab) return true;
    if (this is MouseHoverGesture && (this as MouseHoverGesture).enableHover)
      return true;
    return false;
  }
}
