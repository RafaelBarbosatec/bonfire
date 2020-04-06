import 'package:bonfire/util/rect_component.dart';
import 'package:flutter/cupertino.dart';

mixin Touchable {
  int _pointer;
  void onTap() {}
  void onTapDown(Offset position) {}
  void onTapUp(Offset position) {}
  void handlerTabDown(int pointer, Offset position) {
    if (this is RectComponent) {
      if ((this as RectComponent).position.contains(position)) {
        this._pointer = pointer;
      }
    } else {
      this.onTapDown(position);
    }
  }

  void handlerTabUp(int pointer, Offset position) {
    if (this is RectComponent) {
      if ((this as RectComponent).position.contains(position) &&
          pointer == this._pointer) {
        this.onTap();
      }
    } else {
      this.onTapUp(position);
    }
  }
}
