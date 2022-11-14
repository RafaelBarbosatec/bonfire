import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/mixins/keyboard_listener.dart';
import 'package:bonfire/mixins/pointer_detector.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// CustomBaseGame created to use `Listener` to capture touch screen gestures.
/// Apply zoom in canvas.
/// Reorder components per time frame.
abstract class BaseGame extends FlameGame with PointerDetector, KeyboardEvents {
  BaseGame({Camera? camera}) : super(camera: camera);

  /// variable that keeps the highest rendering priority per frame. This is used to determine the order in which to render the `interface`, `lighting` and `joystick`
  int _highestPriority = 1000000;

  /// Get of the _highestPriority
  int get highestPriority => _highestPriority;

  bool enabledGestures = true;
  bool enabledKeyboard = true;

  /// to get the components that contain gestures
  Iterable<PointerDetectorHandler> get _gesturesComponents {
    return children.where((c) => _hasGesture(c)).cast<PointerDetectorHandler>();
  }

  /// to get the components that contain gestures
  Iterable<KeyboardEventListener> get _keyboardComponents {
    return children
        .where((c) => _hasKeyboardEventListener(c))
        .cast<KeyboardEventListener>();
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
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (!enabledKeyboard) {
      return KeyEventResult.ignored;
    }
    for (final c in _keyboardComponents) {
      if (c.onKeyboard(event, keysPressed)) {
        return super.onKeyEvent(event, keysPressed);
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  /// Verify if the Component contain gestures.
  bool _hasGesture(Component c) {
    return ((c is GameComponent && c.isVisible) || c.isHud) &&
        (c is PointerDetectorHandler &&
            (c as PointerDetectorHandler).hasGesture());
  }

  /// Verify if the Component contain gestures.
  bool _hasKeyboardEventListener(Component c) {
    return c is KeyboardEventListener;
  }

  /// reorder components by priority
  void updateOrderPriority() {
    if (children.isNotEmpty) {
      children.rebalanceAll();
      _highestPriority = children.last.priority;
    }
  }
}
