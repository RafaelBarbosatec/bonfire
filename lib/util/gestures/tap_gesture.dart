import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:flutter/widgets.dart';

mixin TapGesture on GameComponent {
  bool enableTab = true;
  int _pointer = -1;
  void handlerPointerDown(PointerDownEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition;

    if (enableTab && hasGameRef) {
      if (this.isHud) {
        if (this.position.contains(position)) {
          _pointer = pointer;
          onTapDown(pointer, position);
        }
      } else {
        final absolutePosition =
            this.gameRef.camera.screenPositionToWorld(position);
        if (this.position.contains(absolutePosition)) {
          _pointer = pointer;
          onTapDown(pointer, position);
        }
      }
    }
    super.handlerPointerDown(event);
  }

  void handlerPointerUp(PointerUpEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition;

    if (enableTab && pointer == _pointer && hasGameRef) {
      if (this.isHud) {
        if (this.position.contains(position)) {
          onTapUp(pointer, position);
          onTap();
        } else {
          onTapCancel();
        }
      } else {
        final absolutePosition =
            this.gameRef.camera.screenPositionToWorld(position);
        if (this.position.contains(absolutePosition)) {
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

  @override
  void handlerPointerMove(PointerMoveEvent event) {
    if (_pointer != -1) {
      _pointer = -1;
      onTapCancel();
    }
    super.handlerPointerMove(event);
  }

  void onTapDown(int pointer, Offset position);
  void onTapUp(int pointer, Offset position);
  void onTapCancel();
  void onTap();

  bool get receiveInteraction => _pointer != -1;
}
