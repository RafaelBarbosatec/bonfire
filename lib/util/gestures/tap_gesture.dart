import 'dart:ui';

import 'package:bonfire/base/game_component.dart';

mixin TapGesture on GameComponent {
  bool enableTab = true;
  int _pointer;

  void handlerPointerDown(int pointer, Offset position) {
    if (!enableTab) return;
    if (this.isHud()) {
      if (this.position.contains(position)) {
        _pointer = pointer;
        onTapDown(pointer, position);
      }
    } else {
      final absolutePosition =
          this.gameRef.gameCamera.screenPositionToWorld(position);
      if (this.position.contains(absolutePosition)) {
        _pointer = pointer;
        onTapDown(pointer, position);
      }
    }
  }

  void handlerPointerUp(int pointer, Offset position) {
    if (!enableTab || pointer != _pointer) return;
    if (this.isHud()) {
      if (this.position.contains(position)) {
        onTapUp(pointer, position);
        onTap();
      } else {
        onTapCancel();
      }
    } else {
      final absolutePosition =
          this.gameRef.gameCamera.screenPositionToWorld(position);
      if (this.position.contains(absolutePosition)) {
        onTapUp(pointer, position);
        onTap();
      } else {
        onTapCancel();
      }
    }
    _pointer = null;
  }

  void onTapDown(int pointer, Offset position) {}

  void onTapUp(int pointer, Offset position) {}

  void onTapCancel() {}

  void onTap();
}
