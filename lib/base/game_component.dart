import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/bonfire_game_ref.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:bonfire/util/mixins/interval_checker.dart';
import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/widgets.dart';

/// Base of the all components in the Bonfire
abstract class GameComponent extends PositionComponent
    with BonfireHasGameRef, PointerDetectorHandler, InternalChecker {
  final String _keyIntervalCheckIsVisible = "CHECK_VISIBLE";
  final int _intervalCheckIsVisible = 200;
  Map<String, dynamic>? properties;

  /// When true this component render above all components in game.
  bool aboveComponents = false;

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

  /// Method used to translate component
  void translate(double translateX, double translateY) {
    position.add(Vector2(translateX, translateY));
  }

  @override
  int get priority {
    if (aboveComponents && hasGameRef) {
      return LayerPriority.getAbovePriority(gameRef.highestPriority);
    }
    return LayerPriority.getComponentPriority(_getBottomPriority());
  }

  int _getBottomPriority() {
    if (this.isObjectCollision()) {
      return (this as ObjectCollision).rectCollision.bottom.round();
    }
    return bottom.round();
  }

  void renderDebugMode(Canvas canvas) {
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

  @override
  void renderTree(Canvas canvas) {
    canvas.save();
    _applyFlipAndRotation(canvas);
    render(canvas);
    children.forEach((c) => c.renderTree(canvas));

    // Any debug rendering should be rendered on top of everything
    if (debugMode && isVisible) {
      renderDebugMode(canvas);
    }

    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _checkIsVisible(dt);
  }

  void _checkIsVisible(double dt) {
    if (checkInterval(
      _keyIntervalCheckIsVisible,
      _intervalCheckIsVisible,
      dt,
    )) {
      isVisible = this._isVisibleInCamera();
    }
  }

  /// Return screen position of this component.
  Vector2 screenPosition() {
    if (hasGameRef) {
      return gameRef.camera.worldToScreen(
        position,
      );
    }
    return Vector2.zero();
  }

  @override
  void handlerPointerDown(PointerDownEvent event) {
    for (var child in children) {
      if (child is GameComponent) {
        child.handlerPointerDown(event);
      }
    }
  }

  @override
  void handlerPointerUp(PointerUpEvent event) {
    for (var child in children) {
      if (child is GameComponent) {
        child.handlerPointerUp(event);
      }
    }
  }

  @override
  void handlerPointerCancel(PointerCancelEvent event) {
    for (var child in children) {
      if (child is GameComponent) {
        child.handlerPointerCancel(event);
      }
    }
  }

  /// Method that checks if this component is visible on the screen
  bool _isVisibleInCamera() {
    if (hasGameRef) {
      return gameRef.isVisibleInCamera(this) ||
          positionType == PositionType.viewport;
    }
    return false;
  }

  void _applyFlipAndRotation(Canvas canvas) {
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
  }
}
