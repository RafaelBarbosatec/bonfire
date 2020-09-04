import 'dart:ui';

import 'package:bonfire/base/rpg_game.dart';
import 'package:bonfire/util/mixins/gestures.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

abstract class GameComponent extends Component with HasGameRef<RPGGame> {
  /// Position used to draw on the screen
  Rect position;

  int _pointer;

  Offset _startDragOffset;
  Rect _startDragPosition;

  /// Variable used to control whether the component has been destroyed.
  bool _isDestroyed = false;

  void handlerPointerDown(int pointer, Offset position) {
    if (this.position == null || gameRef == null) return;

    if (this.isHud()) {
      if (this.position.contains(position)) {
        if (this is TapGesture) {
          (this as TapGesture).onTapDown(pointer);
        }
        if (this is DragGesture) {
          _startDragOffset = position;
          _startDragPosition = this.position;
          (this as DragGesture).startDrag();
        }
        this._pointer = pointer;
      }
    } else {
      final absolutePosition =
          gameRef.gameCamera.cameraPositionToWorld(position);
      if (this.position.contains(absolutePosition)) {
        if (this is TapGesture) {
          (this as TapGesture).onTapDown(pointer);
        }
        if (this is DragGesture) {
          _startDragOffset = absolutePosition;
          _startDragPosition = this.position;
          (this as DragGesture).startDrag();
        }
        this._pointer = pointer;
      }
    }
  }

  void handlerPointerMove(int pointer, Offset position) {
    if (_startDragOffset != null) {
      if (this.isHud()) {
        if (this is DragGesture) {
          this.position = Rect.fromLTWH(
            _startDragPosition.left + (position.dx - _startDragOffset.dx),
            _startDragPosition.top + (position.dy - _startDragOffset.dy),
            _startDragPosition.width,
            _startDragPosition.height,
          );
          (this as DragGesture).moveDrag(position);
        }
      } else {
        if (this is DragGesture) {
          final absolutePosition =
              gameRef.gameCamera.cameraPositionToWorld(position);
          this.position = Rect.fromLTWH(
            _startDragPosition.left +
                (absolutePosition.dx - _startDragOffset.dx),
            _startDragPosition.top +
                (absolutePosition.dy - _startDragOffset.dy),
            _startDragPosition.width,
            _startDragPosition.height,
          );
          (this as DragGesture).moveDrag(absolutePosition);
        }
      }
    }
  }

  void handlerPointerUp(int pointer, Offset position) {
    if (this.position == null || this._pointer == null) return;

    if (this.isHud()) {
      if (this is TapGesture) {
        (this as TapGesture).onTapUp(pointer, position);
      }
      if (this.position.contains(position) && pointer == this._pointer) {
        if (this is TapGesture) {
          (this as TapGesture).onTap();
        }
      } else {
        if (this is TapGesture) {
          (this as TapGesture).onTapCancel(pointer);
        }
      }
      if (this is DragGesture) {
        _startDragPosition = null;
        _startDragOffset = null;
        (this as DragGesture).endDrag(position);
      }
    } else {
      final absolutePosition =
          gameRef.gameCamera.cameraPositionToWorld(position);
      if (this is TapGesture) {
        (this as TapGesture).onTapUp(pointer, position);
      }
      if (this.position.contains(absolutePosition) &&
          pointer == this._pointer) {
        if (this is TapGesture) {
          (this as TapGesture).onTap();
        }
      } else {
        if (this is TapGesture) {
          (this as TapGesture).onTapCancel(pointer);
        }
      }
      if (this is DragGesture) {
        _startDragPosition = null;
        _startDragOffset = null;
        (this as DragGesture).endDrag(absolutePosition);
      }
    }

    this._pointer = null;
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

  String typeTileBelow() {
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
