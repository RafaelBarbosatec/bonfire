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

  /// When true this component render above all components in game.
  bool aboveComponents = false;

  /// This method remove of the component
  void remove() {
    shouldRemove = true;
  }

  /// Method that checks if this component is visible on the screen
  bool isVisibleInCamera() {
    if (shouldRemove) return false;

    return gameRef.camera.isComponentOnCamera(this);
  }

  /// Method that checks if this component contain collisions
  bool isObjectCollision() {
    return (this is ObjectCollision &&
        (this as ObjectCollision).containCollision());
  }

  /// Method return screen position
  Offset screenPosition() {
    return gameRef.camera.worldPositionToScreen(position.offset);
  }

  /// Method that checks what type map tile is currently
  String? tileTypeBelow() {
    final list = tileTypeListBelow();
    if (list?.isNotEmpty == true) {
      return list?.first;
    }

    return null;
  }

  /// Method that checks what types map tile is currently
  List<String>? tileTypeListBelow() {
    final map = gameRef.map;
    if (map.tiles.isNotEmpty) {
      Vector2Rect position = this.isObjectCollision()
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

  /// Method that checks what properties map tile is currently
  Map<String, dynamic>? tilePropertiesBelow() {
    final list = tilePropertiesListBelow();
    if (list?.isNotEmpty == true) {
      return list?.first;
    }

    return null;
  }

  /// Method that checks what properties list map tile is currently
  List<Map<String, dynamic>>? tilePropertiesListBelow() {
    final map = gameRef.map;
    if (map.tiles.isNotEmpty) {
      Vector2Rect position = this.isObjectCollision()
          ? (this as ObjectCollision).getRectCollision()
          : this.position;
      return map
          .getRendered()
          .where((element) {
            return (element.position.overlaps(position) &&
                (element.properties != null));
          })
          .map<Map<String, dynamic>>((e) => e.properties!)
          .toList();
    }
    return null;
  }

  /// Method used to translate component
  void translate(double translateX, double translateY) {
    position = position.translate(translateX, translateY);
  }

  @override
  int get priority {
    if (aboveComponents) {
      return LayerPriority.getAbovePriority(gameRef.highestPriority);
    }
    return LayerPriority.getComponentPriority(_getBottomPriority());
  }

  int _getBottomPriority() {
    int bottomPriority = position.bottom.round();
    if (this.isObjectCollision()) {
      bottomPriority = (this as ObjectCollision).rectCollision.bottom.round();
    }
    return bottomPriority;
  }

  @override
  bool hasGesture() => true;
}
