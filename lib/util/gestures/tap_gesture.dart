import 'dart:ui';

import 'package:bonfire/base/game_component.dart';

mixin TapGesture on GameComponent {
  bool enableTab = true;
  int _pointer;
  void onTap();
  void onTapDown(int pointer, Offset position) {
    if (!enableTab) return;
    if (this.isHud()) {
      if (this.position.contains(position)) {
        _pointer = pointer;
      }
    } else {
      final absolutePosition =
          this.gameRef.gameCamera.cameraPositionToWorld(position);
      if (this.position.contains(absolutePosition)) {
        _pointer = pointer;
      }
    }
  }

  void onTapUp(int pointer, Offset position) {
    if (!enableTab || pointer != _pointer) return;
    if (this.isHud()) {
      if (this.position.contains(position)) {
        onTap();
      } else {
        onTapCancel();
      }
    } else {
      final absolutePosition =
          this.gameRef.gameCamera.cameraPositionToWorld(position);
      if (this.position.contains(absolutePosition)) {
        onTap();
      } else {
        onTapCancel();
      }
    }
    _pointer = null;
  }

  void onTapCancel() {}
}
