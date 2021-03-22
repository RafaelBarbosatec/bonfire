import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/vector2rect.dart';

mixin DragGesture on GameComponent {
  Offset _startDragOffset;
  Rect _startDragPosition;
  int _pointer;
  bool enableDrag = true;

  void dragStart(int pointer, Offset position) {
    if (!enableDrag) return;
    if (this.isHud) {
      if (this.position.rect.contains(position)) {
        _pointer = pointer;
        _startDragOffset = position;
        _startDragPosition = this.position.rect;
      }
    } else {
      final absolutePosition =
          this.gameRef.gameCamera.screenPositionToWorld(position);
      if (this.position.rect.contains(absolutePosition)) {
        _pointer = pointer;
        _startDragOffset = absolutePosition;
        _startDragPosition = this.position.rect;
      }
    }
  }

  void dragMove(int pointer, Offset position) {
    if (!enableDrag || pointer != _pointer) return;
    if (_startDragOffset != null && this is GameComponent) {
      if (this.isHud) {
        this.position = Vector2Rect.fromRect(
          Rect.fromLTWH(
            _startDragPosition.left + (position.dx - _startDragOffset.dx),
            _startDragPosition.top + (position.dy - _startDragOffset.dy),
            this.position.size.x,
            this.position.size.y,
          ),
        );
      } else {
        final absolutePosition =
            this.gameRef.gameCamera.screenPositionToWorld(position);
        this.position = Vector2Rect.fromRect(
          Rect.fromLTWH(
            _startDragPosition.left +
                (absolutePosition.dx - _startDragOffset.dx),
            _startDragPosition.top +
                (absolutePosition.dy - _startDragOffset.dy),
            this.position.size.x,
            this.position.size.y,
          ),
        );
      }
    }
  }

  void dragEnd(int pointer) {
    if (pointer == _pointer) {
      _startDragPosition = null;
      _startDragOffset = null;
      _pointer = null;
    }
  }

  void dragCancel(int pointerId) {}
}
