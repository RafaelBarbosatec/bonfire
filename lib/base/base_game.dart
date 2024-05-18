import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/pointer_detector.dart';
import 'package:bonfire/util/quadtree_collision/custom_has_quadtree_collision_detection.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// CustomBaseGame created to use `Listener` to capture touch screen gestures.
/// Apply zoom in canvas.
/// Reorder components per time frame.
abstract class BaseGame extends FlameGame
    with
        PointerDetector,
        KeyboardEvents,
        CustomHasQuadTreeCollisionDetection,
        HasTimeScale {
  BaseGame({super.world, super.camera});
  bool enabledGestures = true;
  bool enabledKeyboard = true;

  /// to get the components that contain gestures
  Iterable<PointerDetectorHandler> get _gesturesComponents {
    return [...camera.world!.children, ...camera.viewport.children]
        .where((c) => _hasGesture(c))
        .cast<PointerDetectorHandler>();
  }

  /// to get the components that contain gestures
  Iterable<KeyboardEventListener> get _keyboardComponents {
    return [
      ...camera.world!.children.query<KeyboardEventListener>(),
      ...camera.viewport.children.query<Keyboard>(),
    ];
  }

  @override
  void onPointerCancel(PointerCancelEvent event) {
    if (!hasLayout || !enabledGestures) return;
    for (final c in _gesturesComponents) {
      if (c.handlerPointerCancel(event)) {
        return;
      }
    }
  }

  @override
  void onPointerUp(PointerUpEvent event) {
    if (!hasLayout || !enabledGestures) return;
    for (final c in _gesturesComponents) {
      if (c.handlerPointerUp(event)) {
        return;
      }
    }
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    if (!hasLayout || !enabledGestures) return;
    for (final c in _gesturesComponents) {
      if (c.handlerPointerMove(event)) {
        return;
      }
    }
  }

  @override
  void onPointerDown(PointerDownEvent event) {
    if (!hasLayout || !enabledGestures) return;
    for (final c in _gesturesComponents) {
      if (c.handlerPointerDown(event)) {
        return;
      }
    }
  }

  @override
  void onPointerHover(PointerHoverEvent event) {
    if (!hasLayout || !enabledGestures) return;
    for (final c in _gesturesComponents) {
      if (c.handlerPointerHover(event)) {
        return;
      }
    }
  }

  @override
  void onPointerSignal(PointerSignalEvent event) {
    if (!hasLayout || !enabledGestures) return;
    for (final c in _gesturesComponents) {
      if (c.handlerPointerSignal(event)) {
        return;
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    KeyEventResult result = KeyEventResult.ignored;
    if (!enabledKeyboard) {
      return result;
    }
    for (var listener in _keyboardComponents) {
      if (listener.onKeyboard(event, keysPressed)) {
        result = KeyEventResult.handled;
      }
    }
    return result;
  }

  /// Verify if the Component contain gestures.
  bool _hasGesture(Component c) {
    return ((c is GameComponent && c.isVisible)) && ((c).hasGesture());
  }
}
