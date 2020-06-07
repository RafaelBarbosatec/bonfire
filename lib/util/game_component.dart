import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

abstract class GameComponent extends Component with HasGameRef<RPGGame> {
  /// Position used to draw on the screen
  Rect position;

  int _pointer;

  bool isTouchable = false;

  /// Variable used to control whether the component has been destroyed.
  bool _isDestroyed = false;

  void onTap() {}
  void onTapDown(int pointer, Offset position) {}
  void onTapUp(int pointer, Offset position) {}
  void onTapMove(int pointer, Offset position) {}
  void onTapCancel(int pointer) {}

  void handlerTapDown(int pointer, Offset position) {
    if (this.position == null || gameRef == null) return;

    final absolutePosition = gameRef.gameCamera.cameraPositionToWorld(position);

    if (this.isHud()) {
      this.onTapDown(pointer, position);
      if (this.position.contains(position)) {
        this._pointer = pointer;
      }
    } else {
      this.onTapDown(pointer, absolutePosition);
      if (this.position.contains(absolutePosition)) {
        this._pointer = pointer;
      }
    }
  }

  void handlerTapUp(int pointer, Offset position) {
    if (this.position == null) return;

    final absolutePosition = gameRef.gameCamera.cameraPositionToWorld(position);

    if (this.isHud()) {
      this.onTapUp(pointer, position);
      if (this.position.contains(position) && pointer == this._pointer) {
        this.onTap();
      }
    } else {
      this.onTapUp(pointer, absolutePosition);
      if (this.position.contains(absolutePosition) &&
          pointer == this._pointer) {
        this.onTap();
      }
    }
  }

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {
    position ??= Rect.zero;
  }

  @override
  bool destroy() {
    return _isDestroyed;
  }

  /// This method destroy of the component
  void remove() {
    _isDestroyed = true;
  }

  bool isVisibleInCamera() {
    if (gameRef == null ||
        gameRef?.size == null ||
        position == null ||
        destroy() == true) return false;

    return gameRef.gameCamera.isComponentOnCamera(this);
  }
}
