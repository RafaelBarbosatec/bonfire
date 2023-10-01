import 'package:bonfire/bonfire.dart';
import 'package:flutter/gestures.dart';

mixin PointerDetector {
  void onPointerDown(PointerDownEvent event) {}
  void onPointerMove(PointerMoveEvent event) {}
  void onPointerUp(PointerUpEvent event) {}
  void onPointerCancel(PointerCancelEvent event) {}
  void onPointerHover(PointerHoverEvent event) {}
  void onPointerSignal(PointerSignalEvent event) {}
}

mixin PointerDetectorHandler on Component {
  // If return 'true' this event is not relay to others components.
  bool handlerPointerDown(PointerDownEvent event) {
    for (var child in children) {
      if (child is GameComponent) {
        if (child.handlerPointerDown(event)) {
          return true;
        }
      }
    }
    return false;
  }

  // If return 'true' this event is not relay to others components.
  bool handlerPointerMove(PointerMoveEvent event) {
    for (var child in children) {
      if (child is GameComponent) {
        if (child.handlerPointerMove(event)) {
          return true;
        }
      }
    }
    return false;
  }

  // If return 'true' this event is not relay to others components.
  bool handlerPointerUp(PointerUpEvent event) {
    for (var child in children) {
      if (child is GameComponent) {
        if (child.handlerPointerUp(event)) {
          return true;
        }
      }
    }
    return false;
  }

  // If return 'true' this event is not relay to others components.
  bool handlerPointerCancel(PointerCancelEvent event) {
    for (var child in children) {
      if (child is GameComponent) {
        if (child.handlerPointerCancel(event)) {
          return true;
        }
      }
    }
    return false;
  }

  // If return 'true' this event is not relay to others components.
  bool handlerPointerHover(PointerHoverEvent event) {
    return false;
  }

  // If return 'true' this event is not relay to others components.
  bool handlerPointerSignal(PointerSignalEvent event) {
    return false;
  }

  bool hasGesture() {
    if (this is DragGesture && (this as DragGesture).enableDrag) return true;
    if (this is TapGesture && (this as TapGesture).enableTab) return true;
    if (this is MouseEventListener &&
        (this as MouseEventListener).enableMouseGesture) {
      return true;
    }
    return false;
  }
}
