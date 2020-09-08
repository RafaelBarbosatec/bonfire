import 'dart:ui';

import 'package:bonfire/base/game_component.dart';

mixin DragGesture {
  Offset _startDragOffset;
  Rect _startDragPosition;
  int _pointer;
  bool enableDrag = true;

  void startDrag(int pointer, Offset position) {
    if (!(this is GameComponent) || !enableDrag) return;
    if (_gameComponent.isHud()) {
      if (_gameComponent.position.contains(position)) {
        _pointer = pointer;
        _startDragOffset = position;
        _startDragPosition = _gameComponent.position;
      }
    } else {
      final absolutePosition =
          _gameComponent.gameRef.gameCamera.cameraPositionToWorld(position);
      if (_gameComponent.position.contains(absolutePosition)) {
        _pointer = pointer;
        _startDragOffset = absolutePosition;
        _startDragPosition = _gameComponent.position;
      }
    }
  }

  void moveDrag(int pointer, Offset position) {
    if (!enableDrag || pointer != _pointer) return;
    if (_startDragOffset != null && this is GameComponent) {
      if (_gameComponent.isHud()) {
        _gameComponent.position = Rect.fromLTWH(
          _startDragPosition.left + (position.dx - _startDragOffset.dx),
          _startDragPosition.top + (position.dy - _startDragOffset.dy),
          _startDragPosition.width,
          _startDragPosition.height,
        );
      } else {
        final absolutePosition =
            _gameComponent.gameRef.gameCamera.cameraPositionToWorld(position);
        _gameComponent.position = Rect.fromLTWH(
          _startDragPosition.left + (absolutePosition.dx - _startDragOffset.dx),
          _startDragPosition.top + (absolutePosition.dy - _startDragOffset.dy),
          _startDragPosition.width,
          _startDragPosition.height,
        );
      }
    }
  }

  void endDrag(int pointer) {
    if (pointer == _pointer) {
      _startDragPosition = null;
      _startDragOffset = null;
      _pointer = null;
    }
  }

  GameComponent get _gameComponent => (this as GameComponent);
}
