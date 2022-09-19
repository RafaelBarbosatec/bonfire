import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';
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
      if (isHud) {
        if (containsPoint(position)) {
          _pointer = pointer;
          handler = onTapDown(pointer, position);
        }
      } else {
        final absolutePosition = gameRef.screenToWorld(position);
        if (containsPoint(absolutePosition)) {
          _pointer = pointer;
          handler = onTapDown(pointer, position);
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

  // If return 'true' this event is not relay to others components.
  bool onTapDown(int pointer, Vector2 position) {
    return false;
  }

  void onTapUp(int pointer, Vector2 position) {}
  void onTapCancel() {}
  void onTap();
}
