import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

abstract class GameComponent extends Component with HasGameRef<RPGGame> {
  /// Position used to draw on the screen
  Rect position;

  int _pointer;

  bool isTouchable = false;

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
