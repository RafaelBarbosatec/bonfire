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
  bool handlerPointerDown(PointerDownEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();
    bool handler = false;

    if (enableDrag && hasGameRef) {
      if (isHud) {
        if (containsPoint(position)) {
          _pointer = pointer;
          _startDragOffset = position;
          _startDragPosition = this.position.clone();
          handler = onStartDrag(pointer, position);
        }
      } else {
        final absolutePosition = gameRef.screenToWorld(position);
        if (containsPoint(absolutePosition)) {
          _pointer = pointer;
          _startDragOffset = absolutePosition;
          _startDragPosition = this.position.clone();
          handler = onStartDrag(pointer, position);
        }
      }
    }

    return handler ? handler : super.handlerPointerDown(event);
  }

  @override
  bool handlerPointerMove(PointerMoveEvent event) {
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();
    bool canMove = hasGameRef &&
        _startDragPosition != null &&
        enableDrag &&
        pointer == _pointer;

    if (canMove) {
      if (isHud) {
        this.position = Vector2(
          _startDragPosition!.x + (position.x - _startDragOffset!.x),
          _startDragPosition!.y + (position.y - _startDragOffset!.y),
        );
      } else {
        final absolutePosition = gameRef.screenToWorld(position);
        this.position = Vector2(
          _startDragPosition!.x + (absolutePosition.x - _startDragOffset!.x),
          _startDragPosition!.y + (absolutePosition.y - _startDragOffset!.y),
        );
      }
      inMoving = true;
      onMoveDrag(pointer, position);
    }
    return super.handlerPointerMove(event);
  }

  @override
  bool handlerPointerUp(PointerUpEvent event) {
    final pointer = event.pointer;
    if (pointer == _pointer && inMoving) {
      _startDragPosition = null;
      _startDragOffset = null;
      _pointer = -1;
      inMoving = false;
      onEndDrag(pointer);
    }

    return super.handlerPointerUp(event);
  }

  @override
  bool handlerPointerCancel(PointerCancelEvent event) {
    final pointer = event.pointer;
    if (pointer == _pointer && inMoving) {
      _startDragPosition = null;
      _startDragOffset = null;
      _pointer = -1;
      inMoving = false;
      onCancelDrag(pointer);
    }
    return super.handlerPointerCancel(event);
  }

  // If return 'true' this event is not relay to others components.
  bool onStartDrag(int pointer, Vector2 position) {
    return false;
  }

  void onMoveDrag(int pointer, Vector2 position) {}
  void onEndDrag(int pointer) {}
  void onCancelDrag(int pointer) {}

  bool get receiveInteraction => _pointer != -1;
}
