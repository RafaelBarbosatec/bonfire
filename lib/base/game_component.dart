import 'dart:ui';

import 'package:bonfire/base/rpg_game.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/components.dart';

abstract class GameComponent extends Component with HasGameRef<RPGGame> {
  /// Position used to draw on the screen
  Vector2Rect position;

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {
    position ??= Vector2Rect(Vector2.zero(), Vector2.zero());
  }

  /// This method destroy of the component
  void remove() {
    shouldRemove = true;
  }

  bool isVisibleInCamera() {
    if (gameRef == null ||
        gameRef?.size == null ||
        position == null ||
        shouldRemove) return false;

    return gameRef.gameCamera.isComponentOnCamera(this);
  }

  String tileTypeBelow() {
    final map = gameRef?.map;
    if (map != null && map.tiles.isNotEmpty) {
      Rect position = (this is ObjectCollision)
          ? (this as ObjectCollision).getRectCollision(this.position.rect)
          : this.position;
      final tiles = map.getRendered().where((element) {
        return (element.position.rect.overlaps(position) &&
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
          ? (this as ObjectCollision).getRectCollision(this.position.rect)
          : this.position;
      return map
          .getRendered()
          .where((element) => (element.position.rect.overlaps(position) &&
              (element?.type?.isNotEmpty ?? false)))
          .map<String>((e) => e.type)
          .toList();
    }
    return null;
  }

  void translate(double translateX, double translateY) {
    position =
        Vector2Rect.fromRect(position.rect.translate(translateX, translateY));
  }
}
