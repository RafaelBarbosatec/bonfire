import 'package:bonfire/base/game_component.dart';
import 'package:flutter/gestures.dart';

mixin MouseHoverGesture on GameComponent {
  bool enableHover = true;

  @override
  void handlerPointerHover(PointerHoverEvent event) {
    if (!enableHover) return;
    int pointer = event.pointer;
    Offset position = event.localPosition;
    onHoverScreen(pointer, position);
    if (this.isHud) {
      if (this.position.contains(position)) {
        onHoverIn(pointer, position);
      } else {
        onHoverOut(pointer, position);
      }
    } else {
      final absolutePosition = this.gameRef.screenPositionToWorld(position);
      if (this.position.contains(absolutePosition)) {
        onHoverIn(pointer, position);
      } else {
        onHoverOut(pointer, position);
      }
    }
    super.handlerPointerHover(event);
  }

  void onHoverScreen(int pointer, Offset position);
  void onHoverIn(int pointer, Offset position);
  void onHoverOut(int pointer, Offset position);
}
