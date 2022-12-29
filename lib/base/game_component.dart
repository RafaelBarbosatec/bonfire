import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/paint_transformer.dart';
import 'package:bonfire/mixins/pointer_detector.dart';
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
  @mustCallSuper
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
      onSetIfVisible();
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
    return hasGameRef ? gameRef.isVisibleInCamera(this) : false;
  }

  @override
  @mustCallSuper
  void onRemove() {
    (gameRef as BonfireGame).removeVisible(this);
    super.onRemove();
  }

  void onSetIfVisible() {
    bool nowIsVisible = _isVisibleInCamera();
    if (nowIsVisible && !isVisible) {
      (gameRef as BonfireGame).addVisible(this);
    }
    if (!nowIsVisible && isVisible) {
      (gameRef as BonfireGame).removeVisible(this);
    }
    isVisible = nowIsVisible;
  }

  void onGameDetach() {}
}
