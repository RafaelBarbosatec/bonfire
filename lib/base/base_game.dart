import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';

/// CustomBaseGame created to use `Listener` to capture touch screen gestures.
/// Apply zoom in canvas.
/// Reorder components per time frame.
abstract class BaseGame extends FlameGame with FPSCounter, PointerDetector {
  BaseGame({Camera? camera}) : super(camera: camera);

  /// variable that keeps the highest rendering priority per frame. This is used to determine the order in which to render the `interface`, `lighting` and `joystick`
  int _highestPriority = 1000000;

  /// Get of the _highestPriority
  int get highestPriority => _highestPriority;

  /// to get the components that contain gestures
  Iterable<PointerDetectorHandler> get _gesturesComponents {
    return children.where((c) => _hasGesture(c)).cast<PointerDetectorHandler>();
  }

  @override
  void onPointerCancel(PointerCancelEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerCancel(event);
    }
  }

  @override
  void onPointerUp(PointerUpEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerUp(event);
    }
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerMove(event);
    }
  }

  @override
  void onPointerDown(PointerDownEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerDown(event);
    }
  }

  @override
  void onPointerHover(PointerHoverEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerHover(event);
    }
  }

  @override
  void onPointerSignal(PointerSignalEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerSignal(event);
    }
  }

  /// Verify if the Component contain gestures.
  bool _hasGesture(Component c) {
    return ((c is GameComponent && c.isVisible) || c.isHud) &&
        (c is PointerDetectorHandler &&
            (c as PointerDetectorHandler).hasGesture());
  }

  /// reorder components by priority
  void updateOrderPriority() {
    if (children.length > 0) {
      children.rebalanceAll();
      _highestPriority = children.last.priority;
    }
  }
}
