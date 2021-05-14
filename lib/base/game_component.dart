import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

/// Base of the all components in the Bonfire
abstract class GameComponent extends Component
    with HasGameRef<BonfireGame>, PointerDetectorHandler {
  /// Position used to draw on the screen
  Vector2Rect position = Vector2Rect.zero();

  /// This method remove of the component
  void remove() {
    shouldRemove = true;
  }

  /// Method that checks if this component is visible on the screen
  bool isVisibleInCamera() {
    if (shouldRemove) return false;

    return gameRef.camera.isComponentOnCamera(this);
  }

  /// Method return screen position
  Offset screenPosition() {
    return gameRef.camera.worldPositionToScreen(position.offset);
  }

  /// Method that checks what type map tile is currently
  String? tileTypeBelow() {
    final map = gameRef.map;
    if (map.tiles.isNotEmpty) {
      Vector2Rect position = (this is ObjectCollision)
          ? (this as ObjectCollision).getRectCollision()
          : this.position;
      final tiles = map.getRendered().where((element) {
        return (element.position.overlaps(position) &&
            (element.type?.isNotEmpty ?? false));
      });
      if (tiles.isNotEmpty) return tiles.first.type;
    }
    return null;
  }

  /// Method that checks what types map tile is currently
  List<String>? tileTypesBelow() {
    final map = gameRef.map;
    if (map.tiles.isNotEmpty) {
      Vector2Rect position = (this is ObjectCollision)
          ? (this as ObjectCollision).getRectCollision()
          : this.position;
      return map
          .getRendered()
          .where((element) {
            return (element.position.overlaps(position) &&
                (element.type?.isNotEmpty ?? false));
          })
          .map<String>((e) => e.type!)
          .toList();
    }
    return null;
  }

  void translate(double translateX, double translateY) {
    position = position.translate(translateX, translateY);
  }

  @override
  int get priority => LayerPriority.getComponentPriority(_getBottomPriority());

  int _getBottomPriority() {
    int bottomPriority = position.bottom.round();
    if (this is ObjectCollision &&
        (this as ObjectCollision).containCollision()) {
      bottomPriority = (this as ObjectCollision).rectCollision.bottom.round();
    }
    return bottomPriority;
  }

  @override
  bool hasGesture() => true;
}
