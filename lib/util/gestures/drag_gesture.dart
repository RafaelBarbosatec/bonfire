import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/widgets.dart';

mixin DragGesture on GameComponent {
  Offset? _startDragOffset;
  Vector2Rect? _startDragPosition;
  int _pointer = -1;
  bool enableDrag = true;
  bool inMoving = false;

  @override
  void handlerPointerDown(PointerDownEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition;

    if (enableDrag && hasGameRef) {
      if (this.isHud) {
        if (this.position.contains(position)) {
          _pointer = pointer;
          _startDragOffset = position;
          _startDragPosition = this.position;
          startDrag(pointer, position);
        }
      } else {
        final absolutePosition =
            this.gameRef.camera.screenPositionToWorld(position);
        if (this.position.contains(absolutePosition)) {
          _pointer = pointer;
          _startDragOffset = absolutePosition;
          _startDragPosition = this.position;
        }
      }
    }

    super.handlerPointerDown(event);
  }

  @override
  void handlerPointerMove(PointerMoveEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition;
    bool canMove = hasGameRef &&
        _startDragPosition != null &&
        enableDrag &&
        pointer == _pointer;

    if (canMove) {
      if (this.isHud) {
        this.position = Rect.fromLTWH(
          _startDragPosition!.left + (position.dx - _startDragOffset!.dx),
          _startDragPosition!.top + (position.dy - _startDragOffset!.dy),
          _startDragPosition!.width,
          _startDragPosition!.height,
        ).toVector2Rect();
      } else {
        final absolutePosition =
            this.gameRef.camera.screenPositionToWorld(position);
        this.position = Rect.fromLTWH(
          _startDragPosition!.left +
              (absolutePosition.dx - _startDragOffset!.dx),
          _startDragPosition!.top +
              (absolutePosition.dy - _startDragOffset!.dy),
          _startDragPosition!.width,
          _startDragPosition!.height,
        ).toVector2Rect();
      }
      inMoving = true;
      moveDrag(pointer, position);
    }
    super.handlerPointerMove(event);
  }

  @override
  void handlerPointerUp(PointerUpEvent event) {
    final pointer = event.pointer;
    if (pointer == _pointer && inMoving) {
      _startDragPosition = null;
      _startDragOffset = null;
      _pointer = -1;
      inMoving = false;
      endDrag(pointer);
    }

    super.handlerPointerUp(event);
  }

  @override
  void handlerPointerCancel(PointerCancelEvent event) {
    final pointer = event.pointer;
    if (pointer == _pointer && inMoving) {
      _startDragPosition = null;
      _startDragOffset = null;
      _pointer = -1;
      inMoving = false;
      cancelDrag(pointer);
    }
    super.handlerPointerCancel(event);
  }

  void startDrag(int pointer, Offset position) {}
  void moveDrag(int pointer, Offset position) {}
  void endDrag(int pointer) {}
  void cancelDrag(int pointer) {}

  bool get receiveInteraction => _pointer != -1;
}
