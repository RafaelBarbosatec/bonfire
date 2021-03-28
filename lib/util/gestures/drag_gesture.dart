import 'dart:ui';

import 'package:bonfire/base/game_component.dart';

mixin DragGesture on GameComponent {
  Offset _startDragOffset;
  Rect _startDragPosition;
  int _pointer;
  bool enableDrag = true;
  @override
  void handlerPointerDown(int pointer, Offset position) {
    if (!(this is GameComponent) || !enableDrag) return;
    if (this.isHud()) {
      if (this.position.contains(position)) {
        _pointer = pointer;
        _startDragOffset = position;
        _startDragPosition = this.position;
        startDrag(pointer, position);
      }
    } else {
      final absolutePosition =
          this.gameRef.gameCamera.screenPositionToWorld(position);
      if (this.position.contains(absolutePosition)) {
        _pointer = pointer;
        _startDragOffset = absolutePosition;
        _startDragPosition = this.position;
      }
    }
  }

  @override
  void handlerPointerMove(int pointer, Offset position) {
    if (!enableDrag || pointer != _pointer) return;
    if (_startDragOffset != null && this is GameComponent) {
      if (this.isHud()) {
        this.position = Rect.fromLTWH(
          _startDragPosition.left + (position.dx - _startDragOffset.dx),
          _startDragPosition.top + (position.dy - _startDragOffset.dy),
          _startDragPosition.width,
          _startDragPosition.height,
        );
      } else {
        final absolutePosition =
            this.gameRef.gameCamera.screenPositionToWorld(position);
        this.position = Rect.fromLTWH(
          _startDragPosition.left + (absolutePosition.dx - _startDragOffset.dx),
          _startDragPosition.top + (absolutePosition.dy - _startDragOffset.dy),
          _startDragPosition.width,
          _startDragPosition.height,
        );
      }
      moveDrag(pointer, position);
    }
  }

  @override
  void handlerPointerUp(int pointer, Offset position) {
    if (pointer == _pointer) {
      _startDragPosition = null;
      _startDragOffset = null;
      _pointer = null;
      endDrag(pointer);
    }
  }

  @override
  void handlerPointerCancel(int pointer) {
    if (pointer == _pointer) {
      _startDragPosition = null;
      _startDragOffset = null;
      _pointer = null;
      cancelDrag(pointer);
    }
  }

  void startDrag(int pointer, Offset position) {}
  void moveDrag(int pointer, Offset position) {}
  void endDrag(int pointer) {}
  void cancelDrag(int pointer) {}
}
