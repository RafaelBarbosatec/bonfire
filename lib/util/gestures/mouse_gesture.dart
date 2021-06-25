import 'package:bonfire/base/game_component.dart';
import 'package:flutter/gestures.dart';

/// Mixin responsible to listen mouse gestures
mixin MouseGesture on GameComponent {
  bool enableMouseGesture = true;

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
}
