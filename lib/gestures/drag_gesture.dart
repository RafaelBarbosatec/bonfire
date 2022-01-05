import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

mixin DragGesture on GameComponent {
  Vector2? _startDragOffset;
  Vector2? _startDragPosition;
  int _pointer = -1;
  bool enableDrag = true;
  bool inMoving = false;

  @override
  void handlerPointerDown(PointerDownEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();

    if (enableDrag && hasGameRef) {
      if (this.isHud) {
        if (containsPoint(position)) {
          _pointer = pointer;
          _startDragOffset = position;
          _startDragPosition = this.position.clone();
          onStartDrag(pointer, position);
        }
      } else {
        final absolutePosition = this.gameRef.screenToWorld(position);
        if (containsPoint(absolutePosition)) {
          _pointer = pointer;
          _startDragOffset = absolutePosition;
          _startDragPosition = this.position.clone();
        }
      }
    }

    super.handlerPointerDown(event);
  }

  @override
  void handlerPointerMove(PointerMoveEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();
    bool canMove = hasGameRef &&
        _startDragPosition != null &&
        enableDrag &&
        pointer == _pointer;

    if (canMove) {
      if (this.isHud) {
        this.position = Vector2(
          _startDragPosition!.x + (position.x - _startDragOffset!.x),
          _startDragPosition!.y + (position.y - _startDragOffset!.y),
        );
      } else {
        final absolutePosition = this.gameRef.screenToWorld(position);
        this.position = Vector2(
          _startDragPosition!.x + (absolutePosition.x - _startDragOffset!.x),
          _startDragPosition!.y + (absolutePosition.y - _startDragOffset!.y),
        );
      }
      inMoving = true;
      onMoveDrag(pointer, position);
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
      onEndDrag(pointer);
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
      onCancelDrag(pointer);
    }
    super.handlerPointerCancel(event);
  }

  void onStartDrag(int pointer, Vector2 position) {}
  void onMoveDrag(int pointer, Vector2 position) {}
  void onEndDrag(int pointer) {}
  void onCancelDrag(int pointer) {}

  bool get receiveInteraction => _pointer != -1;
}
