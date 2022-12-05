import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/gestures.dart';

enum MouseButton { left, right, middle, unknow }

/// Mixin responsible to listen mouse gestures
mixin MouseGesture on GameComponent {
  bool enableMouseGesture = true;
  int _pointer = -1;
  bool _hoverEnter = false;
  MouseButton? _buttonClicked;

  /// Listen to the mouse cursor across the screen
  void onMouseHoverScreen(int pointer, Vector2 position) {}

  /// Listen when the mouse cursor hover in this component
  void onMouseHoverEnter(int pointer, Vector2 position) {}

  /// Listen when the mouse cursor passes outside this component
  void onMouseHoverExit(int pointer, Vector2 position) {}

  /// Listen when use scroll of the mouse across the screen
  void onMouseScrollScreen(
      int pointer, Vector2 position, Vector2 scrollDelta) {}

  /// Listen when use scroll of the mouse in your component
  void onMouseScroll(int pointer, Vector2 position, Vector2 scrollDelta) {}

  void onMouseTapDown(int pointer, Vector2 position, MouseButton button) {}
  void onMouseTapUp(int pointer, Vector2 position, MouseButton button) {}

  // Listen when mouse clicked in your component
  void onMouseTap(MouseButton button);
  void onMouseCancel() {}

  @override
  bool handlerPointerHover(PointerHoverEvent event) {
    if (!enableMouseGesture) {
      return super.handlerPointerHover(event);
    }
    int pointer = event.pointer;
    Vector2 position = event.localPosition.toVector2();
    Vector2 realPosition = position;
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
    int pointer = event.pointer;
    Vector2 position = event.localPosition.toVector2();
    Vector2 realPosition = event.localPosition.toVector2();
    if (!isHud) {
      realPosition = gameRef.screenToWorld(realPosition);
    }
    Vector2 scrollDelta = (event as PointerScrollEvent).scrollDelta.toVector2();
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

  void onMouseScreenTapDown(int pointer, Vector2 position, MouseButton button) {
    Vector2 realPosition = position;
    if (!isHud) {
      realPosition = gameRef.screenToWorld(realPosition);
    }
    if (containsPoint(realPosition)) {
      _buttonClicked = button;
      _pointer = pointer;
      onMouseTapDown(pointer, position, button);
    }
  }

  void onMouseScreenTapUp(int pointer, Vector2 position) {
    Vector2 realPosition = position;
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
}
