import 'dart:ui';

import 'package:bonfire/base/game_component.dart';

mixin TapGesture {
  bool enableTab = true;
  int _pointer;
  void onTap();
  void onTapDown(int pointer, Offset position) {
    if (!(this is GameComponent) || !enableTab) return;
    if (_gameComponent.isHud()) {
      if (_gameComponent.position.contains(position)) {
        _pointer = pointer;
      }
    } else {
      final absolutePosition =
          _gameComponent.gameRef.gameCamera.cameraPositionToWorld(position);
      if (_gameComponent.position.contains(absolutePosition)) {
        _pointer = pointer;
      }
    }
  }

  void onTapUp(int pointer, Offset position) {
    if (!enableTab || pointer != _pointer) return;
    if (_gameComponent.isHud()) {
      if (_gameComponent.position.contains(position)) {
        onTap();
      } else {
        onTapCancel();
      }
    } else {
      final absolutePosition =
          _gameComponent.gameRef.gameCamera.cameraPositionToWorld(position);
      if (_gameComponent.position.contains(absolutePosition)) {
        onTap();
      } else {
        onTapCancel();
      }
    }
    _pointer = null;
  }

  void onTapCancel() {}

  GameComponent get _gameComponent => (this as GameComponent);
}
