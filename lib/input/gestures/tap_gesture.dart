import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

mixin TapGesture on GameComponent {
  bool enableTab = true;
  int _pointer = -1;
  @override
  bool handlerPointerDown(PointerDownEvent event) {
    final tapEvent = GestureEvent.fromPointerEvent(
      event,
      screenToWorld: gameRef.screenToWorld,
      globalToViewportPosition: gameRef.globalToViewportPosition,
    );
    var handler = false;

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
    final tapEvent = GestureEvent.fromPointerEvent(
      event,
      screenToWorld: gameRef.screenToWorld,
      globalToViewportPosition: gameRef.globalToViewportPosition,
    );

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
  bool onTapDown(GestureEvent event) {
    return false;
  }

  // It's called when happen tap up in the component
  void onTapUp(GestureEvent event) {}
  // It's called when happen canceled tap in the component
  void onTapCancel() {}

  // It's called when happen tap in the component
  void onTap();

  // It's called when happen tap down in the screen
  void onTapDownScreen(GestureEvent event) {}
  // It's called when happen tap up in the screen
  void onTapUpScreen(GestureEvent event) {}

  @override
  bool hasGesture() => true;
}
