import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

mixin TapGesture on GameComponent {
  bool enableTab = true;
  int _pointer = -1;
  @override
  bool handlerPointerDown(PointerDownEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();
    bool handler = false;

    if (enableTab && hasGameRef) {
      onTapDownScreen(pointer, position);
      if (isHud) {
        if (containsPoint(position)) {
          _pointer = pointer;
          handler = onTapDown(pointer, position);
        }
      } else {
        final worldPosition = gameRef.screenToWorld(position);
        if (containsPoint(worldPosition)) {
          _pointer = pointer;
          handler = onTapDown(pointer, worldPosition);
        }
      }
    }
    return handler ? handler : super.handlerPointerDown(event);
  }

  @override
  bool handlerPointerUp(PointerUpEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();

    if (enableTab && pointer == _pointer && hasGameRef) {
      onTapUpScreen(pointer, position);
      if (isHud) {
        if (containsPoint(position)) {
          onTapUp(pointer, position);
          onTap();
        } else {
          onTapCancel();
        }
      } else {
        final absolutePosition = gameRef.screenToWorld(position);
        if (containsPoint(absolutePosition)) {
          onTapUp(pointer, position);
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
  bool onTapDown(int pointer, Vector2 position) {
    return false;
  }

  // It's called when happen tap up in the component
  void onTapUp(int pointer, Vector2 position) {}
  // It's called when happen canceled tap in the component
  void onTapCancel() {}

  // It's called when happen tap in the component
  void onTap();

  // It's called when happen tap down in the screen
  void onTapDownScreen(int pointer, Vector2 position) {}
  // It's called when happen tap up in the screen
  void onTapUpScreen(int pointer, Vector2 position) {}
}
