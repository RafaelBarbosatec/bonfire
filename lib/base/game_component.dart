import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/bonfire_game_ref.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:bonfire/util/interval_tick.dart';
import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/widgets.dart';

/// Base of the all components in the Bonfire
abstract class GameComponent extends PositionComponent
    with BonfireHasGameRef, PointerDetectorHandler {
  Map<String, dynamic>? properties;

  /// When true this component render above all components in game.
  bool aboveComponents = false;

  /// Map available to store times that can be used to control the frequency of any action.
  Map<String, IntervalTick> _timers = Map();

  /// Use to set opacity in render
  /// Range [0.0..1.0]
  double opacity = 1.0;

  /// Rotation angle (in radians) of the component. The component will be
  /// rotated around its anchor point in the clockwise direction if the
  /// angle is positive, or counterclockwise if the angle is negative.
  double angle = 0;

  /// Use to do vertical flip in de render.
  bool isFlipVertical = false;

  /// Use to do horizontal flip in de render.
  bool isFlipHorizontal = false;

  /// Param checks if this component is visible on the screen
  bool isVisible = false;

  /// Get BuildContext
  BuildContext get context => gameRef.context;

  /// Method that checks if this component is visible on the screen
  bool _isVisibleInCamera() {
    if (!hasGameRef) return false;
    return gameRef.isVisibleInCamera(this);
  }

  /// Method that checks if this component contain collisions
  bool isObjectCollision() {
    return (this is ObjectCollision &&
        (this as ObjectCollision).containCollision());
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
    if (map.getRendered().isNotEmpty) {
      Rect position = this.isObjectCollision()
          ? (this as ObjectCollision).rectCollision
          : this.toRect();
      return map
          .getRendered()
          .where((element) {
            return (element.overlaps(position) &&
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
      Rect position = this.isObjectCollision()
          ? (this as ObjectCollision).rectCollision
          : this.toRect();
      return map
          .getRendered()
          .where((element) {
            return (element.overlaps(position) && (element.properties != null));
          })
          .map<Map<String, dynamic>>((e) => e.properties!)
          .toList();
    }
    return null;
  }

  /// Method used to translate component
  void translate(double translateX, double translateY) {
    position.add(Vector2(translateX, translateY));
  }

  @override
  int get priority {
    if (aboveComponents) {
      return LayerPriority.getAbovePriority(gameRef.highestPriority);
    }
    return LayerPriority.getComponentPriority(_getBottomPriority());
  }

  int _getBottomPriority() {
    int bottomPriority = bottom.round();
    if (this.isObjectCollision()) {
      bottomPriority = (this as ObjectCollision).rectCollision.bottom.round();
    }
    return bottomPriority;
  }

  void renderDebugMode(Canvas canvas) {
    if (isVisible) {
      final rect = toRect();
      canvas.drawRect(rect, debugPaint);

      final dx = rect.right;
      final dy = rect.bottom;
      debugTextPaint.render(
        canvas,
        'x:${dx.toStringAsFixed(2)} y:${dy.toStringAsFixed(2)}',
        Vector2(dx - 50, dy),
      );
    }
  }

  @override
  void renderTree(Canvas canvas) {
    canvas.save();

    if (isFlipHorizontal || isFlipVertical || angle != 0) {
      canvas.translate(this.center.x, this.center.y);
      if (angle != 0) {
        canvas.rotate(angle);
      }
      if (isFlipHorizontal || isFlipVertical) {
        canvas.scale(isFlipHorizontal ? -1 : 1, isFlipVertical ? -1 : 1);
      }

      canvas.translate(-this.center.x, -this.center.y);
    }

    render(canvas);

    canvas.restore();

    children.forEach((c) => c.renderTree(canvas));

    // Any debug rendering should be rendered on top of everything
    if (debugMode) {
      renderDebugMode(canvas);
    }
  }

  /// Returns true if for each time the defined millisecond interval passes.
  /// Like a `Timer.periodic`
  /// Used in flows involved in the [update]
  bool checkInterval(String key, int intervalInMilli, double dt) {
    if (this._timers[key]?.interval != intervalInMilli) {
      this._timers[key] = IntervalTick(intervalInMilli);
      return true;
    } else {
      return this._timers[key]?.update(dt) ?? false;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    isVisible = this._isVisibleInCamera();
  }

  /// Return screen position of this component.
  Vector2 screenPosition() {
    if (hasGameRef) {
      return gameRef.camera.worldToScreen(
        position,
      );
    } else {
      return Vector2.zero();
    }
  }

  @override
  void handlerPointerDown(PointerDownEvent event) {
    children.forEach((i) {
      if (i is GameComponent) {
        i.handlerPointerDown(event);
      }
    });
  }

  @override
  void handlerPointerUp(PointerUpEvent event) {
    children.forEach((i) {
      if (i is GameComponent) {
        i.handlerPointerUp(event);
      }
    });
  }

  @override
  void handlerPointerCancel(PointerCancelEvent event) {
    children.forEach((i) {
      if (i is GameComponent) {
        i.handlerPointerCancel(event);
      }
    });
  }
}
