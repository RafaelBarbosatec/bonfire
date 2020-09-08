import 'dart:ui';

import 'package:bonfire/base/rpg_game.dart';
import 'package:bonfire/util/gestures/drag_gesture.dart';
import 'package:bonfire/util/gestures/tap_gesture.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

abstract class GameComponent extends Component with HasGameRef<RPGGame> {
  /// Position used to draw on the screen
  Rect position;

  /// Variable used to control whether the component has been destroyed.
  bool _isDestroyed = false;

  void handlerPointerDown(int pointer, Offset position) {
    if (this.position == null || gameRef == null) return;

    if (this is TapGesture) {
      (this as TapGesture).onTapDown(pointer, position);
    }
    if (this is DragGesture) {
      (this as DragGesture).startDrag(pointer, position);
    }
  }

  void handlerPointerMove(int pointer, Offset position) {
    if (this is DragGesture) {
      (this as DragGesture).moveDrag(pointer, position);
    }
  }

  void handlerPointerUp(int pointer, Offset position) {
    if (this.position == null) return;
    if (this is TapGesture) {
      (this as TapGesture).onTapUp(pointer, position);
    }

    if (this is DragGesture) {
      (this as DragGesture).endDrag(pointer);
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

  String tileTypeBelow() {
    final map = gameRef?.map;
    if (map != null && map.tiles.isNotEmpty) {
      final tiles = map
          .getRendered()
          .where((element) => element.position.overlaps(position));
      if (tiles.isNotEmpty) return tiles.first.type;
    }
    return null;
  }

  void translate(double translateX, double translateY) {
    position = position.translate(translateX, translateY);
  }
}
