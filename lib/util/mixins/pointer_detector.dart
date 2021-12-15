import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/gestures/drag_gesture.dart';
import 'package:bonfire/gestures/mouse_gesture.dart';
import 'package:bonfire/gestures/tap_gesture.dart';
import 'package:flame/components.dart';
import 'package:flutter/gestures.dart';

mixin PointerDetector {
  void onPointerDown(PointerDownEvent event) {}
  void onPointerMove(PointerMoveEvent event) {}
  void onPointerUp(PointerUpEvent event) {}
  void onPointerCancel(PointerCancelEvent event) {}
  void onPointerHover(PointerHoverEvent event) {}
  void onPointerSignal(PointerSignalEvent event) {}
}

abstract class PointerDetectorHandler {
  void handlerPointerDown(PointerDownEvent event) {}
  void handlerPointerMove(PointerMoveEvent event) {}
  void handlerPointerUp(PointerUpEvent event) {}
  void handlerPointerCancel(PointerCancelEvent event) {}
  void handlerPointerHover(PointerHoverEvent event) {}
  void handlerPointerSignal(PointerSignalEvent event) {}

  bool hasGesture() {
    if (this is DragGesture && (this as DragGesture).enableDrag) return true;
    if (this is TapGesture && (this as TapGesture).enableTab) return true;
    if (this is MouseGesture && (this as MouseGesture).enableMouseGesture)
      return true;
    return false;
  }
}

typedef TapInGame = void Function(
  BonfireGame game,
  Vector2 screenPosition,
  Vector2 worldPosition,
);
