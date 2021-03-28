import 'dart:ui';

import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

abstract class GameComponent extends Component with HasGameRef<BonfireGame> {
  /// Position used to draw on the screen
  Rect position;

  /// Variable used to control whether the component has been destroyed.
  bool _isDestroyed = false;

  void handlerPointerDown(int pointer, Offset position) {}
  void handlerPointerMove(int pointer, Offset position) {}
  void handlerPointerUp(int pointer, Offset position) {}
  void handlerPointerCancel(int pointer) {}

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
      Rect position = (this is ObjectCollision)
          ? (this as ObjectCollision).getRectCollision(this.position)
          : this.position;
      final tiles = map.getRendered().where((element) {
        return (element.position.overlaps(position) &&
            (element?.type?.isNotEmpty ?? false));
      });
      if (tiles.isNotEmpty) return tiles.first.type;
    }
    return null;
  }

  List<String> tileTypesBelow() {
    final map = gameRef?.map;
    if (map != null && map.tiles.isNotEmpty) {
      Rect position = (this is ObjectCollision)
          ? (this as ObjectCollision).getRectCollision(this.position)
          : this.position;
      return map
          .getRendered()
          .where((element) => (element.position.overlaps(position) &&
              (element?.type?.isNotEmpty ?? false)))
          .map<String>((e) => e.type)
          .toList();
    }
    return null;
  }

  void translate(double translateX, double translateY) {
    position = position.translate(translateX, translateY);
  }
}
