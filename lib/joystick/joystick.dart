import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

export 'package:bonfire/joystick/keyboard_config.dart';

class Joystick extends JoystickController {
  final List<JoystickAction> actions;
  JoystickDirectional? _directional;

  JoystickDirectional? get directional => _directional;

  bool _directionalIsIdle = false;

  Joystick({
    this.actions = const [],
    JoystickDirectional? directional,
    KeyboardConfig? keyboardConfig,
  }) {
    _directional = directional;
    if (keyboardConfig != null) {
      this.keyboardConfig = keyboardConfig;
    }
  }

  void initialize(Vector2 size) async {
    directional?.initialize(size, this);
    for (var action in actions) {
      action.initialize(size, this);
    }
  }

  Future updateDirectional(JoystickDirectional? directional) async {
    directional?.initialize(gameRef.size, this);
    await directional?.onLoad();
    _directional = directional;
  }

  Future addAction(JoystickAction action) async {
    action.initialize(gameRef.size, this);
    await action.onLoad();
    actions.add(action);
  }

  void removeAction(dynamic actionId) {
    actions.removeWhere((action) => action.actionId == actionId);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    directional?.render(canvas);
    for (JoystickAction action in actions) {
      action.render(canvas);
    }
  }

  @override
  void update(double dt) {
    directional?.update(dt);
    for (JoystickAction action in actions) {
      action.update(dt);
    }
    super.update(dt);
  }

  @override
  bool handlerPointerCancel(PointerCancelEvent event) {
    for (JoystickAction action in actions) {
      action.actionUp(event.pointer);
    }
    directional?.directionalUp(event.pointer);
    return super.handlerPointerCancel(event);
  }

  @override
  bool handlerPointerDown(PointerDownEvent event) {
    directional?.directionalDown(event.pointer, event.localPosition);
    for (JoystickAction action in actions) {
      action.actionDown(event.pointer, event.localPosition);
    }
    return super.handlerPointerDown(event);
  }

  @override
  bool handlerPointerMove(PointerMoveEvent event) {
    for (JoystickAction action in actions) {
      action.actionMove(event.pointer, event.localPosition);
    }
    directional?.directionalMove(event.pointer, event.localPosition);
    return super.handlerPointerMove(event);
  }

  @override
  bool handlerPointerUp(PointerUpEvent event) {
    for (JoystickAction action in actions) {
      action.actionUp(event.pointer);
    }
    directional?.directionalUp(event.pointer);
    return super.handlerPointerUp(event);
  }

  @override
  bool onKeyboard(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    /// If the keyboard is disabled, we do not process the event
    if (!keyboardConfig.enable) return false;

    /// If the key is not accepted, we do not process the event
    if (keyboardConfig.acceptedKeys != null) {
      if (!keyboardConfig.acceptedKeys!.contains(event.logicalKey)) {
        return false;
      }
    }

    /// No keyboard events, keep idle
    if (!_containDirectionalPressed(keysPressed) &&
        !event.repeat &&
        !_directionalIsIdle) {
      _directionalIsIdle = true;
      joystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.IDLE,
          intensity: 0.0,
          radAngle: 0.0,
        ),
      );
    }

    /// Process directional events
    if (_isDirectional(event.logicalKey)) {
      final currentKeyboardKeys = _getDirectionlKeysPressed(keysPressed);
      if (currentKeyboardKeys.isNotEmpty) {
        _directionalIsIdle = false;
        if (keyboardConfig.enableDiagonalInput &&
            currentKeyboardKeys.length > 1) {
          _sendTwoDirection(
            currentKeyboardKeys.first,
            currentKeyboardKeys[1],
          );
        } else {
          _sendOneDirection(currentKeyboardKeys.first);
        }
      }
    } else {
      /// Process action events
      if (event is RawKeyDownEvent) {
        joystickAction(
          JoystickActionEvent(
            id: event.logicalKey,
            event: ActionEvent.DOWN,
          ),
        );
      } else if (event is RawKeyUpEvent) {
        joystickAction(
          JoystickActionEvent(
            id: event.logicalKey,
            event: ActionEvent.UP,
          ),
        );
      }
    }

    return true;
  }

  @override
  void onGameResize(Vector2 size) {
    initialize(size);
    super.onGameResize(size);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await directional?.onLoad();
    for (var ac in actions) {
      await ac.onLoad();
    }
  }

  /// Check if the key is for directional [arrows, wasd, or both]
  bool _isDirectional(LogicalKeyboardKey key) {
    return keyboardConfig.directionalKeys.contain(key);
  }

  void _sendOneDirection(LogicalKeyboardKey key) {
    if (keyboardConfig.directionalKeys.up == key) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP,
        intensity: 1.0,
        radAngle: 0.0,
        isKeyboard: true,
      ));
    }
    if (keyboardConfig.directionalKeys.down == key) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN,
        intensity: 1.0,
        radAngle: 0.0,
        isKeyboard: true,
      ));
    }

    if (keyboardConfig.directionalKeys.left == key) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
        isKeyboard: true,
      ));
    }

    if (keyboardConfig.directionalKeys.right == key) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
        isKeyboard: true,
      ));
    }
  }

  void _sendTwoDirection(LogicalKeyboardKey key1, LogicalKeyboardKey key2) {
    if (key1 == keyboardConfig.directionalKeys.right &&
            key2 == keyboardConfig.directionalKeys.down ||
        key1 == keyboardConfig.directionalKeys.down &&
            key2 == keyboardConfig.directionalKeys.right) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
        isKeyboard: true,
      ));
    }

    if (key1 == keyboardConfig.directionalKeys.left &&
            key2 == keyboardConfig.directionalKeys.down ||
        key1 == keyboardConfig.directionalKeys.down &&
            key2 == keyboardConfig.directionalKeys.left) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
        isKeyboard: true,
      ));
    }

    if (key1 == keyboardConfig.directionalKeys.left &&
            key2 == keyboardConfig.directionalKeys.up ||
        key1 == keyboardConfig.directionalKeys.up &&
            key2 == keyboardConfig.directionalKeys.left) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
        isKeyboard: true,
      ));
    }

    if (key1 == keyboardConfig.directionalKeys.right &&
            key2 == keyboardConfig.directionalKeys.up ||
        key1 == keyboardConfig.directionalKeys.up &&
            key2 == keyboardConfig.directionalKeys.right) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
        isKeyboard: true,
      ));
    }
  }

  bool _containDirectionalPressed(Set<LogicalKeyboardKey> keysPressed) {
    for (var element in keysPressed) {
      if (_isDirectional(element)) {
        return true;
      }
    }
    return false;
  }

  List<LogicalKeyboardKey> _getDirectionlKeysPressed(
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    return keysPressed.where(_isDirectional).toList();
  }
}
