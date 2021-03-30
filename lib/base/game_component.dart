import 'dart:ui';

import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/components.dart';

abstract class GameComponent extends Component
    with HasGameRef<BonfireGame>, PointerDetectorHandler {
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
      Vector2Rect position = (this is ObjectCollision)
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
      Vector2Rect position = (this is ObjectCollision)
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
    position =
        Vector2Rect.fromRect(position.rect.translate(translateX, translateY));
  }

  @override
  int get priority => LayerPriority.getPriorityFromMap(_getBottomPriority());

  int _getBottomPriority() {
    if (this is ObjectCollision) {
      return (this as ObjectCollision).rectCollision?.bottom?.round() ?? 0.0;
    }
    return position?.bottom?.round() ?? 0;
  }
}
