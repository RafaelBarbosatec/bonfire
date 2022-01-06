import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

mixin TapGesture on GameComponent {
  bool enableTab = true;
  int _pointer = -1;
  void handlerPointerDown(PointerDownEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();

    if (enableTab && hasGameRef) {
      if (this.isHud) {
        if (this.containsPoint(position)) {
          _pointer = pointer;
          onTapDown(pointer, position);
        }
      } else {
        final absolutePosition = this.gameRef.screenToWorld(position);
        if (this.containsPoint(absolutePosition)) {
          _pointer = pointer;
          onTapDown(pointer, position);
        }
      }
    }
    super.handlerPointerDown(event);
  }

  void handlerPointerUp(PointerUpEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();

    if (enableTab && pointer == _pointer && hasGameRef) {
      if (this.isHud) {
        if (this.containsPoint(position)) {
          onTapUp(pointer, position);
          onTap();
        } else {
          onTapCancel();
        }
      } else {
        final absolutePosition = this.gameRef.screenToWorld(position);
        if (this.containsPoint(absolutePosition)) {
          onTapUp(pointer, position);
          onTap();
        } else {
          onTapCancel();
        }
      }
      _pointer = -1;
    }

    super.handlerPointerUp(event);
  }

  void onTapDown(int pointer, Vector2 position);
  void onTapUp(int pointer, Vector2 position);
  void onTapCancel();
  void onTap();

  bool get receiveInteraction => _pointer != -1;
}
