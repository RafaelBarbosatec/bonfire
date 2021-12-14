import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';
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
    Offset position = event.localPosition;
    onHoverScreen(pointer, position);
    if (this.isHud) {
      if (this.position.contains(position)) {
        onHoverEnter(pointer, position);
      } else {
        onHoverExit(pointer, position);
      }
    } else {
      final absolutePosition = this.gameRef.screenPositionToWorld(position);
      if (this.position.contains(absolutePosition)) {
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
    Offset position = event.localPosition;
    Offset scrollDelta = (event as PointerScrollEvent).scrollDelta;
    onScrollScreen(pointer, position, scrollDelta);
    if (this.isHud) {
      if (this.position.contains(position)) {
        onScroll(pointer, position, scrollDelta);
      }
    } else {
      final absolutePosition = this.gameRef.screenPositionToWorld(position);
      if (this.position.contains(absolutePosition)) {
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
    final position = event.localPosition;
    if (hasGameRef) {
      if (this.isHud) {
        if (this.position.contains(position)) {
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
        final absolutePosition = this.gameRef.screenPositionToWorld(position);
        if (this.position.contains(absolutePosition)) {
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
    final position = event.localPosition;
    if (pointer == _pointer && hasGameRef) {
      if (this.isHud) {
        if (this.position.contains(position)) {
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
        final absolutePosition = this.gameRef.screenPositionToWorld(position);
        if (this.position.contains(absolutePosition)) {
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
  void onHoverScreen(int pointer, Offset position) {}

  /// Listen when the mouse cursor hover in this component
  void onHoverEnter(int pointer, Offset position);

  /// Listen when the mouse cursor passes outside this component
  void onHoverExit(int pointer, Offset position);

  /// Listen when use scroll of the mouse across the screen
  void onScrollScreen(int pointer, Offset position, Offset scrollDelta) {}

  /// Listen when use scroll of the mouse in your component
  void onScroll(int pointer, Offset position, Offset scrollDelta);

  void onMouseTapDownLeft(int pointer, Offset position) {}
  void onMouseTapDownRight(int pointer, Offset position) {}
  void onMouseTapDownMiddle(int pointer, Offset position) {}
  void onMouseTapUpLeft(int pointer, Offset position) {}
  void onMouseTapUpRight(int pointer, Offset position) {}
  void onMouseTapUpMiddle(int pointer, Offset position) {}

  void onMouseTapLeft();
  void onMouseTapRight();
  void onMouseTapMiddle();
  void onMouseCancel();
}
