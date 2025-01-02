import 'package:bonfire/bonfire.dart';
import 'package:flutter/gestures.dart';

enum MouseButton { left, right, middle, unknow }

/// Mixin responsible to listen mouse gestures
mixin MouseEventListener on GameComponent {
  bool enableMouseGesture = true;
  int _pointer = -1;
  bool _hoverEnter = false;
  MouseButton? _buttonClicked;

  /// Listen to the mouse cursor across the screen
  void onMouseHoverScreen(int pointer, Vector2 position) {}

  /// Listen to the mouse move with some button clicked across the screen
  void onMouseMoveScreen(int pointer, Vector2 position, MouseButton button) {}

  /// Listen when the mouse cursor hover in this component
  void onMouseHoverEnter(int pointer, Vector2 position) {}

  /// Listen when the mouse cursor passes outside this component
  void onMouseHoverExit(int pointer, Vector2 position) {}

  /// Listen when use scroll of the mouse across the screen
  void onMouseScrollScreen(
    int pointer,
    Vector2 position,
    Vector2 scrollDelta,
  ) {}

  /// Listen when use scroll of the mouse in your component
  void onMouseScroll(int pointer, Vector2 position, Vector2 scrollDelta) {}

  /// Listen when mouse is clicked down in your component
  void onMouseTapDown(int pointer, Vector2 position, MouseButton button) {}

  /// Listen when mouse is clicked up in your component
  void onMouseTapUp(int pointer, Vector2 position, MouseButton button) {}

  // Listen when mouse clicked in your component
  void onMouseTap(MouseButton button);
  void onMouseCancel() {}

  @override
  bool handlerPointerMove(PointerMoveEvent event) {
    if (event.kind == PointerDeviceKind.mouse) {
      final pointer = event.pointer;
      final position = event.localPosition.toVector2();
      onMouseMoveScreen(pointer, position, _getMouseButtonByInt(event.buttons));
    }
    return super.handlerPointerMove(event);
  }

  @override
  bool handlerPointerHover(PointerHoverEvent event) {
    if (!enableMouseGesture) {
      return super.handlerPointerHover(event);
    }
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();
    var realPosition = position;
    if (!isHud) {
      realPosition = gameRef.screenToWorld(realPosition);
    }
    onMouseHoverScreen(pointer, position);

    if (containsPoint(realPosition) && !_hoverEnter) {
      _hoverEnter = true;
      onMouseHoverEnter(pointer, position);
    } else if (!containsPoint(realPosition) && _hoverEnter) {
      _hoverEnter = false;
      onMouseHoverExit(pointer, position);
    }

    return super.handlerPointerHover(event);
  }

  @override
  bool handlerPointerSignal(PointerSignalEvent event) {
    if (!enableMouseGesture) {
      return super.handlerPointerSignal(event);
    }
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();
    var realPosition = event.localPosition.toVector2();
    if (!isHud) {
      realPosition = gameRef.screenToWorld(realPosition);
    }
    final scrollDelta = (event as PointerScrollEvent).scrollDelta.toVector2();
    onMouseScrollScreen(pointer, position, scrollDelta);
    if (containsPoint(realPosition)) {
      onMouseScroll(pointer, position, scrollDelta);
    }
    return super.handlerPointerSignal(event);
  }

  @override
  bool handlerPointerDown(PointerDownEvent event) {
    if (!enableMouseGesture || event.kind != PointerDeviceKind.mouse) {
      return super.handlerPointerDown(event);
    }
    if (hasGameRef) {
      onMouseScreenTapDown(
        event.pointer,
        event.localPosition.toVector2(),
        _getMouseButtonByInt(event.buttons),
      );
    }
    return super.handlerPointerDown(event);
  }

  @override
  bool handlerPointerUp(PointerUpEvent event) {
    if (!enableMouseGesture || event.kind != PointerDeviceKind.mouse) {
      return super.handlerPointerUp(event);
    }

    if (hasGameRef) {
      onMouseScreenTapUp(
        event.pointer,
        event.localPosition.toVector2(),
      );
      _pointer = -1;
    }
    return super.handlerPointerUp(event);
  }

  // Listen when mouse is clicked down in screen
  void onMouseScreenTapDown(int pointer, Vector2 position, MouseButton button) {
    var realPosition = position;
    if (!isHud) {
      realPosition = gameRef.screenToWorld(realPosition);
    }
    if (containsPoint(realPosition)) {
      _buttonClicked = button;
      _pointer = pointer;
      onMouseTapDown(pointer, position, button);
    }
  }

  // Listen when mouse is clicked up in screen
  void onMouseScreenTapUp(int pointer, Vector2 position) {
    var realPosition = position;
    if (!isHud) {
      realPosition = gameRef.screenToWorld(realPosition);
    }
    if (containsPoint(realPosition) &&
        pointer == _pointer &&
        _buttonClicked != null) {
      onMouseTapUp(pointer, position, _buttonClicked!);
      onMouseTap(_buttonClicked!);
    } else if (_buttonClicked != null) {
      onMouseCancel();
    }
    _buttonClicked = null;
  }

  MouseButton _getMouseButtonByInt(int buttonClicked) {
    switch (buttonClicked) {
      case kPrimaryMouseButton:
        return MouseButton.left;
      case kSecondaryMouseButton:
        return MouseButton.right;
      case kMiddleMouseButton:
        return MouseButton.middle;
    }

    return MouseButton.unknow;
  }

  @override
  bool hasGesture() => enableMouseGesture;
}
