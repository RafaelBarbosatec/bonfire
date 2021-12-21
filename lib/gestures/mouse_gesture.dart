import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/gestures.dart';

/// Mixin responsible to listen mouse gestures
mixin MouseGesture on GameComponent {
  bool enableMouseGesture = true;
  int _pointer = -1;
  int _buttonClicked = 0;

  @override
  void handlerPointerHover(PointerHoverEvent event) {
    if (!enableMouseGesture) return;
    int pointer = event.pointer;
    Vector2 position = event.localPosition.toVector2();
    onHoverScreen(pointer, position);
    if (this.isHud) {
      if (containsPoint(position)) {
        onHoverEnter(pointer, position);
      } else {
        onHoverExit(pointer, position);
      }
    } else {
      final absolutePosition = this.gameRef.screenToWorld(position);
      if (containsPoint(absolutePosition)) {
        onHoverEnter(pointer, position);
      } else {
        onHoverExit(pointer, position);
      }
    }
    super.handlerPointerHover(event);
  }

  @override
  void handlerPointerSignal(PointerSignalEvent event) {
    if (!enableMouseGesture) return;
    int pointer = event.pointer;
    Vector2 position = event.localPosition.toVector2();
    Vector2 scrollDelta = (event as PointerScrollEvent).scrollDelta.toVector2();
    onScrollScreen(pointer, position, scrollDelta);
    if (this.isHud) {
      if (containsPoint(position)) {
        onScroll(pointer, position, scrollDelta);
      }
    } else {
      final absolutePosition = this.gameRef.screenToWorld(position);
      if (containsPoint(absolutePosition)) {
        onScroll(pointer, position, scrollDelta);
      }
    }
    super.handlerPointerSignal(event);
  }

  @override
  void handlerPointerDown(PointerDownEvent event) {
    if (!enableMouseGesture) return;
    if (event.kind != PointerDeviceKind.mouse) return;
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();
    if (hasGameRef) {
      if (this.isHud) {
        if (containsPoint(position)) {
          _pointer = pointer;
          _buttonClicked = event.buttons;

          switch (_buttonClicked) {
            case kPrimaryMouseButton:
              onMouseTapDownLeft(pointer, position);
              break;
            case kSecondaryMouseButton:
              onMouseTapDownRight(pointer, position);
              break;
            case kMiddleMouseButton:
              onMouseTapDownMiddle(pointer, position);
              break;
          }
        }
      } else {
        final absolutePosition = this.gameRef.screenToWorld(position);
        if (containsPoint(absolutePosition)) {
          _pointer = pointer;
          _buttonClicked = event.buttons;
          switch (_buttonClicked) {
            case kPrimaryMouseButton:
              onMouseTapDownLeft(pointer, position);
              break;
            case kSecondaryMouseButton:
              onMouseTapDownRight(pointer, position);
              break;
            case kMiddleMouseButton:
              onMouseTapDownMiddle(pointer, position);
              break;
          }
        }
      }
    }
    super.handlerPointerDown(event);
  }

  @override
  void handlerPointerUp(PointerUpEvent event) {
    if (!enableMouseGesture) return;
    if (event.kind != PointerDeviceKind.mouse) return;
    final pointer = event.pointer;
    final position = event.localPosition.toVector2();
    if (pointer == _pointer && hasGameRef) {
      if (this.isHud) {
        if (containsPoint(position)) {
          switch (_buttonClicked) {
            case kPrimaryMouseButton:
              onMouseTapUpLeft(pointer, position);
              onMouseTapLeft();
              break;
            case kSecondaryMouseButton:
              onMouseTapUpRight(pointer, position);
              onMouseTapRight();
              break;
            case kMiddleMouseButton:
              onMouseTapUpMiddle(pointer, position);
              onMouseTapMiddle();
              break;
          }
        } else {
          onMouseCancel();
        }
      } else {
        final absolutePosition = this.gameRef.screenToWorld(position);
        if (containsPoint(absolutePosition)) {
          switch (_buttonClicked) {
            case kPrimaryMouseButton:
              onMouseTapUpLeft(pointer, position);
              onMouseTapLeft();
              break;
            case kSecondaryMouseButton:
              onMouseTapUpRight(pointer, position);
              onMouseTapRight();
              break;
            case kMiddleMouseButton:
              onMouseTapUpMiddle(pointer, position);
              onMouseTapMiddle();
              break;
          }
        } else {
          onMouseCancel();
        }
      }
      _pointer = -1;
    }
    super.handlerPointerUp(event);
  }

  /// Listen to the mouse cursor across the screen
  void onHoverScreen(int pointer, Vector2 position) {}

  /// Listen when the mouse cursor hover in this component
  void onHoverEnter(int pointer, Vector2 position);

  /// Listen when the mouse cursor passes outside this component
  void onHoverExit(int pointer, Vector2 position);

  /// Listen when use scroll of the mouse across the screen
  void onScrollScreen(int pointer, Vector2 position, Vector2 scrollDelta) {}

  /// Listen when use scroll of the mouse in your component
  void onScroll(int pointer, Vector2 position, Vector2 scrollDelta);

  void onMouseTapDownLeft(int pointer, Vector2 position) {}
  void onMouseTapDownRight(int pointer, Vector2 position) {}
  void onMouseTapDownMiddle(int pointer, Vector2 position) {}
  void onMouseTapUpLeft(int pointer, Vector2 position) {}
  void onMouseTapUpRight(int pointer, Vector2 position) {}
  void onMouseTapUpMiddle(int pointer, Vector2 position) {}

  void onMouseTapLeft();
  void onMouseTapRight();
  void onMouseTapMiddle();
  void onMouseCancel();
}
