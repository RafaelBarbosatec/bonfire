import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

mixin DragGesture on GameComponent {
  Vector2? _startDragOffset;
  Vector2? _startDragPosition;
  int _pointer = -1;
  bool enableDrag = true;
  bool inMoving = false;

  @override
  bool handlerPointerDown(PointerDownEvent event) {
    final gEvent = GestureEvent.fromPointerEvent(
      event,
      screenToWorld: gameRef.screenToWorld,
    );
    bool handler = false;

    if (enableDrag && hasGameRef) {
      if (isHud) {
        if (containsPoint(gEvent.screenPosition)) {
          _pointer = gEvent.pointer;
          _startDragOffset = gEvent.screenPosition;
          _startDragPosition = position.clone();
          handler = onStartDrag(gEvent);
        }
      } else {
        if (containsPoint(gEvent.worldPosition)) {
          _pointer = gEvent.pointer;
          _startDragOffset = gEvent.worldPosition;
          _startDragPosition = position.clone();
          handler = onStartDrag(gEvent);
        }
      }
    }

    return handler ? handler : super.handlerPointerDown(event);
  }

  @override
  bool handlerPointerMove(PointerMoveEvent event) {
    final gEvent = GestureEvent.fromPointerEvent(
      event,
      screenToWorld: gameRef.screenToWorld,
    );
    bool canMove = hasGameRef &&
        _startDragPosition != null &&
        enableDrag &&
        gEvent.pointer == _pointer;

    if (canMove) {
      if (isHud) {
        position = Vector2(
          _startDragPosition!.x +
              (gEvent.screenPosition.x - _startDragOffset!.x),
          _startDragPosition!.y +
              (gEvent.screenPosition.y - _startDragOffset!.y),
        );
      } else {
        position = Vector2(
          _startDragPosition!.x +
              (gEvent.worldPosition.x - _startDragOffset!.x),
          _startDragPosition!.y +
              (gEvent.worldPosition.y - _startDragOffset!.y),
        );
      }
      inMoving = true;
      onMoveDrag(gEvent);
    }
    return super.handlerPointerMove(event);
  }

  @override
  bool handlerPointerUp(PointerUpEvent event) {
    final gEvent = GestureEvent.fromPointerEvent(
      event,
      screenToWorld: gameRef.screenToWorld,
    );
    if (gEvent.pointer == _pointer && inMoving) {
      _startDragPosition = null;
      _startDragOffset = null;
      _pointer = -1;
      inMoving = false;
      onEndDrag(gEvent);
    }

    return super.handlerPointerUp(event);
  }

  @override
  bool handlerPointerCancel(PointerCancelEvent event) {
    final gEvent = GestureEvent.fromPointerEvent(
      event,
      screenToWorld: gameRef.screenToWorld,
    );
    if (gEvent.pointer == _pointer && inMoving) {
      _startDragPosition = null;
      _startDragOffset = null;
      _pointer = -1;
      inMoving = false;
      onCancelDrag(gEvent);
    }
    return super.handlerPointerCancel(event);
  }

  // Called when star drag gesture in the component
  // If return 'true' this event is not relay to others components.(default = false)
  bool onStartDrag(GestureEvent event) {
    return false;
  }

  // Called when component is moved
  void onMoveDrag(GestureEvent event) {}
  // Called when component finish drag
  void onEndDrag(GestureEvent event) {}
  // Called when drag is canceled
  void onCancelDrag(GestureEvent event) {}

  bool get receiveInteraction => _pointer != -1;
}
