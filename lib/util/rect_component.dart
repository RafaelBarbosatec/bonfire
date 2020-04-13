import 'dart:ui';

import 'package:bonfire/util/game_component.dart';
import 'package:flutter/gestures.dart';

abstract class RectComponent extends GameComponent {
  /// Position used to draw on the screen
  Rect position;

  /// Position used to locate component in the world.
  ///
  /// This position takes into account the current position of the camera in the world.
  Rect positionInWorld;

  /// Variable used to control whether the component has been destroyed.
  bool _isDestroyed = false;

  bool isTouchable = false;

  int _pointer;

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {
    position = positionInWordToPosition();
  }

  @override
  bool destroy() {
    return _isDestroyed;
  }

  /// This method destroy of the component
  void remove() {
    _isDestroyed = true;
  }

  bool isVisibleInMap() {
    if (gameRef == null || gameRef.size == null) return false;

    return position.top < (gameRef.size.height + position.height) &&
        position.top > (position.height * -1) &&
        position.left > (position.width * -1) &&
        position.left < (gameRef.size.width + position.width) &&
        !destroy();
  }

  Rect positionInWordToPosition() {
    if (gameRef == null) return positionInWorld;
    if (positionInWorld == null) return Rect.zero;
    return Rect.fromLTWH(
      positionInWorld.left + gameRef.gameCamera.position.x,
      positionInWorld.top + gameRef.gameCamera.position.y,
      positionInWorld.width,
      positionInWorld.height,
    );
  }

  void onTap() {}
  void onTapDown(int pointer, Offset position) {}
  void onTapUp(int pointer, Offset position) {}
  void onTapMove(int pointer, Offset position) {}
  void onTapCancel(int pointer) {}

  void handlerTabDown(int pointer, Offset position) {
    this.onTapDown(pointer, position);
    if (this.position.contains(position)) {
      this._pointer = pointer;
    }
  }

  void handlerTabUp(int pointer, Offset position) {
    this.onTapUp(pointer, position);
    if (this.position.contains(position) && pointer == this._pointer) {
      this.onTap();
    }
  }
}
