import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/bonfire_game_ref.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:bonfire/util/mixins/interval_checker.dart';
import 'package:bonfire/util/mixins/paint_transformer.dart';
import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

/// Base of the all components in the Bonfire
abstract class GameComponent extends PositionComponent
    with
        BonfireHasGameRef,
        PointerDetectorHandler,
        InternalChecker,
        RenderTransformer,
        HasPaint {
  final String _keyIntervalCheckIsVisible = "CHECK_VISIBLE";
  final int _intervalCheckIsVisible = 250;
  Map<String, dynamic>? properties;

  /// When true this component render above all components in game.
  bool aboveComponents = false;

  /// Use to set opacity in render
  /// Range [0.0..1.0]
  double get opacity => getOpacity();
  set opacity(double opacoty) => setOpacity(opacity);

  /// Param checks if this component is visible on the screen
  bool isVisible = false;

  bool enabledCheckIsVisible = true;

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
    if (isObjectCollision()) {
      return (this as ObjectCollision).rectCollision.bottom.round();
    }
    return bottom.round();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _checkIsVisible(dt);
  }

  void _checkIsVisible(double dt) {
    if (!enabledCheckIsVisible) return;
    if (checkInterval(
      _keyIntervalCheckIsVisible,
      _intervalCheckIsVisible,
      dt,
    )) {
      isVisible = _isVisibleInCamera();
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
  bool handlerPointerDown(PointerDownEvent event) {
    for (var child in children) {
      if (child is GameComponent) {
        if (child.handlerPointerDown(event)) {
          return true;
        }
      }
    }
    return super.handlerPointerDown(event);
  }

  @override
  bool handlerPointerUp(PointerUpEvent event) {
    for (var child in children) {
      if (child is GameComponent) {
        if (child.handlerPointerUp(event)) {
          return true;
        }
      }
    }
    return super.handlerPointerUp(event);
  }

  @override
  bool handlerPointerCancel(PointerCancelEvent event) {
    for (var child in children) {
      if (child is GameComponent) {
        if (child.handlerPointerCancel(event)) {
          return true;
        }
      }
    }
    return super.handlerPointerCancel(event);
  }

  /// Method that checks if this component is visible on the screen
  bool _isVisibleInCamera() {
    if (hasGameRef) {
      return gameRef.isVisibleInCamera(this) ||
          positionType == PositionType.viewport;
    }
    return false;
  }

  void onGameDetach() {}
}
