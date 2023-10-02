import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class TapGestureEvent {
  final int pointer;
  final Vector2 screenPosition;
  Vector2 worldPosition;
  final PointerDeviceKind kind;

  TapGestureEvent({
    required this.pointer,
    required this.screenPosition,
    Vector2? worldPosition,
    required this.kind,
  }) : worldPosition = worldPosition ?? Vector2.zero();

  factory TapGestureEvent.fromPointerEvent(PointerEvent event) {
    return TapGestureEvent(
      pointer: event.pointer,
      kind: event.kind,
      screenPosition: event.localPosition.toVector2(),
    );
  }
}

mixin TapGesture on GameComponent {
  bool enableTab = true;
  int _pointer = -1;
  @override
  bool handlerPointerDown(PointerDownEvent event) {
    final tapEvent = TapGestureEvent.fromPointerEvent(event);
    tapEvent.worldPosition = gameRef.screenToWorld(tapEvent.screenPosition);
    bool handler = false;

    if (enableTab && hasGameRef) {
      onTapDownScreen(tapEvent);
      if (isHud) {
        if (containsPoint(tapEvent.screenPosition)) {
          _pointer = tapEvent.pointer;
          handler = onTapDown(tapEvent);
        }
      } else {
        if (containsPoint(tapEvent.worldPosition)) {
          _pointer = tapEvent.pointer;
          handler = onTapDown(tapEvent);
        }
      }
    }
    return handler ? handler : super.handlerPointerDown(event);
  }

  @override
  bool handlerPointerUp(PointerUpEvent event) {
    final tapEvent = TapGestureEvent.fromPointerEvent(event);
    tapEvent.worldPosition = gameRef.screenToWorld(tapEvent.screenPosition);

    if (enableTab && tapEvent.pointer == _pointer && hasGameRef) {
      onTapUpScreen(tapEvent);
      if (isHud) {
        if (containsPoint(tapEvent.screenPosition)) {
          onTapUp(tapEvent);
          onTap();
        } else {
          onTapCancel();
        }
      } else {
        if (containsPoint(tapEvent.worldPosition)) {
          onTapUp(tapEvent);
          onTap();
        } else {
          onTapCancel();
        }
      }
      _pointer = -1;
    }

    return super.handlerPointerUp(event);
  }

  // It's called when happen tap down in the component
  // If return 'true' this event is not relay to others components.(default = false)
  bool onTapDown(TapGestureEvent event) {
    return false;
  }

  // It's called when happen tap up in the component
  void onTapUp(TapGestureEvent event) {}
  // It's called when happen canceled tap in the component
  void onTapCancel() {}

  // It's called when happen tap in the component
  void onTap();

  // It's called when happen tap down in the screen
  void onTapDownScreen(TapGestureEvent event) {}
  // It's called when happen tap up in the screen
  void onTapUpScreen(TapGestureEvent event) {}
}
