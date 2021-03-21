import 'dart:ui';

import 'package:bonfire/base/game_component.dart';

mixin TapGesture on GameComponent {
  bool enableTab = true;
  int _pointer;
  void onTap();
  void onTapCancel();
  void handleTapDown(int pointer, Offset position) {
    if (!enableTab) return;
    if (this.isHud) {
      if (this.position.rect.contains(position)) {
        _pointer = pointer;
      }
    } else {
      final absolutePosition =
          this.gameRef.gameCamera.screenPositionToWorld(position);
      if (this.position.rect.contains(absolutePosition)) {
        _pointer = pointer;
      }
    }
  }

  void handleTapUp(int pointer, Offset position) {
    if (!enableTab || pointer != _pointer) return;
    if (this.isHud) {
      if (this.position.rect.contains(position)) {
        onTap();
      } else {
        onTapCancel();
      }
    } else {
      final absolutePosition =
          this.gameRef.gameCamera.screenPositionToWorld(position);
      if (this.position.rect.contains(absolutePosition)) {
        onTap();
      } else {
        onTapCancel();
      }
    }
    _pointer = null;
  }

  void handleTapCancel(int pointer) {
    if (!enableTab || pointer != _pointer) return;
    onTapCancel();
    _pointer = null;
  }
}
