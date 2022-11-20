import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum KeyboardDirectionalType { arrows, wasd, wasdAndArrows }

class KeyboardConfig {
  /// Use to enable ou disable keyboard events
  final bool enable;

  /// Type of the directional (arrows, wasd or wasdAndArrows)
  final KeyboardDirectionalType keyboardDirectionalType;

  /// You can pass specific Keys accepted. If null accept all keys
  final List<LogicalKeyboardKey>? acceptedKeys;

  KeyboardConfig({
    this.enable = true,
    this.keyboardDirectionalType = KeyboardDirectionalType.arrows,
    this.acceptedKeys,
  }) {
    if (acceptedKeys != null) {
      switch (keyboardDirectionalType) {
        case KeyboardDirectionalType.arrows:
          acceptedKeys?.add(LogicalKeyboardKey.arrowLeft);
          acceptedKeys?.add(LogicalKeyboardKey.arrowRight);
          acceptedKeys?.add(LogicalKeyboardKey.arrowDown);
          acceptedKeys?.add(LogicalKeyboardKey.arrowUp);
          break;
        case KeyboardDirectionalType.wasd:
          acceptedKeys?.add(LogicalKeyboardKey.keyW);
          acceptedKeys?.add(LogicalKeyboardKey.keyS);
          acceptedKeys?.add(LogicalKeyboardKey.keyA);
          acceptedKeys?.add(LogicalKeyboardKey.keyD);
          break;
        case KeyboardDirectionalType.wasdAndArrows:
          acceptedKeys?.add(LogicalKeyboardKey.keyW);
          acceptedKeys?.add(LogicalKeyboardKey.keyS);
          acceptedKeys?.add(LogicalKeyboardKey.keyA);
          acceptedKeys?.add(LogicalKeyboardKey.keyD);
          acceptedKeys?.add(LogicalKeyboardKey.arrowLeft);
          acceptedKeys?.add(LogicalKeyboardKey.arrowRight);
          acceptedKeys?.add(LogicalKeyboardKey.arrowDown);
          acceptedKeys?.add(LogicalKeyboardKey.arrowUp);
          break;
      }
    }
  }
}

class Joystick extends JoystickController {
  final List<JoystickAction> actions;
  JoystickDirectional? _directional;

  JoystickDirectional? get directional => _directional;
  final List<LogicalKeyboardKey> _currentKeyboardKeys = [];

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
      final acceptedKeys = keyboardConfig.acceptedKeys!;
      if (!acceptedKeys.contains(event.logicalKey)) {
        return false;
      }
    }

    /// No keyboard events, keep idle
    if (keysPressed.isEmpty && !event.repeat) {
      resetDirectionalKeys();
      joystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.IDLE,
          intensity: 0.0,
          radAngle: 0.0,
        ),
      );
    } else {
      /// Process directional events
      if (_isDirectional(event.logicalKey) && !event.repeat) {
        resetDirectionalKeys();
        _currentKeyboardKeys.addAll(keysPressed.toList());

        if (_currentKeyboardKeys.length == 1) {
          _sendOneDirection(_currentKeyboardKeys.first);
        } else {
          _sendTwoDirection(
            _currentKeyboardKeys.first,
            _currentKeyboardKeys[1],
          );
        }
      } else {
        /// Process action events
        if (event is RawKeyDownEvent) {
          joystickAction(JoystickActionEvent(
            id: event.logicalKey.keyId,
            event: ActionEvent.DOWN,
          ));
        } else if (event is RawKeyUpEvent) {
          joystickAction(JoystickActionEvent(
            id: event.logicalKey.keyId,
            event: ActionEvent.UP,
          ));
        }
      }
    }

    return false;
  }

  @override
  void onGameResize(Vector2 size) {
    initialize(gameRef.camera.canvasSize);
    super.onGameResize(size);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await directional?.onLoad();
    await Future.forEach<JoystickAction>(
      actions,
      (element) => element.onLoad(),
    );
  }

  /// Check if the key is for directional [arrows, wasd, or both]
  bool _isDirectional(LogicalKeyboardKey key) {
    if (keyboardConfig.keyboardDirectionalType ==
        KeyboardDirectionalType.arrows) {
      return key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowDown;
    } else if (keyboardConfig.keyboardDirectionalType ==
        KeyboardDirectionalType.wasd) {
      return key == LogicalKeyboardKey.keyA ||
          key == LogicalKeyboardKey.keyW ||
          key == LogicalKeyboardKey.keyD ||
          key == LogicalKeyboardKey.keyS;
    } else {
      return key == LogicalKeyboardKey.keyA ||
          key == LogicalKeyboardKey.keyW ||
          key == LogicalKeyboardKey.keyD ||
          key == LogicalKeyboardKey.keyS ||
          key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowDown;
    }
  }

  void _sendOneDirection(LogicalKeyboardKey key) {
    switch (keyboardConfig.keyboardDirectionalType) {
      case KeyboardDirectionalType.arrows:
        _oneDirectionArrows(key);
        break;
      case KeyboardDirectionalType.wasd:
        _oneDirectionWASD(key);
        break;
      case KeyboardDirectionalType.wasdAndArrows:
        _oneDirectionWASDAndArrows(key);
    }
  }

  void _oneDirectionWASD(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.keyD) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.keyW) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.keyA) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.keyS) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }
  }

  void _oneDirectionArrows(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowRight) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }
  }

  void _oneDirectionWASDAndArrows(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.keyD ||
        key == LogicalKeyboardKey.arrowRight) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.arrowUp) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.keyA || key == LogicalKeyboardKey.arrowLeft) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.keyS || key == LogicalKeyboardKey.arrowDown) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }
  }

  void _sendTwoDirection(LogicalKeyboardKey key1, LogicalKeyboardKey key2) {
    switch (keyboardConfig.keyboardDirectionalType) {
      case KeyboardDirectionalType.arrows:
        _twoDirectionsArrows(key1, key2);
        break;
      case KeyboardDirectionalType.wasd:
        _twoDirectionsWASD(key1, key2);
        break;
      case KeyboardDirectionalType.wasdAndArrows:
        _twoDirectionsWASDAndArrows(key1, key2);
        break;
    }
  }

  void _twoDirectionsWASD(LogicalKeyboardKey key1, LogicalKeyboardKey key2) {
    if (key1 == LogicalKeyboardKey.keyD && key2 == LogicalKeyboardKey.keyS ||
        key2 == LogicalKeyboardKey.keyD && key1 == LogicalKeyboardKey.keyS) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key1 == LogicalKeyboardKey.keyA && key2 == LogicalKeyboardKey.keyS ||
        key2 == LogicalKeyboardKey.keyA && key1 == LogicalKeyboardKey.keyS) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key1 == LogicalKeyboardKey.keyA && key2 == LogicalKeyboardKey.keyW ||
        key2 == LogicalKeyboardKey.keyA && key1 == LogicalKeyboardKey.keyW) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key1 == LogicalKeyboardKey.keyD && key2 == LogicalKeyboardKey.keyW ||
        key2 == LogicalKeyboardKey.keyD && key1 == LogicalKeyboardKey.keyW) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }
  }

  void _twoDirectionsArrows(LogicalKeyboardKey key1, LogicalKeyboardKey key2) {
    if (key1 == LogicalKeyboardKey.arrowRight &&
            key2 == LogicalKeyboardKey.arrowDown ||
        key2 == LogicalKeyboardKey.arrowRight &&
            key1 == LogicalKeyboardKey.arrowDown) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key1 == LogicalKeyboardKey.arrowLeft &&
            key2 == LogicalKeyboardKey.arrowDown ||
        key2 == LogicalKeyboardKey.arrowLeft &&
            key1 == LogicalKeyboardKey.arrowDown) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key1 == LogicalKeyboardKey.arrowLeft &&
            key2 == LogicalKeyboardKey.arrowUp ||
        key2 == LogicalKeyboardKey.arrowLeft &&
            key1 == LogicalKeyboardKey.arrowUp) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key1 == LogicalKeyboardKey.arrowRight &&
            key2 == LogicalKeyboardKey.arrowUp ||
        key2 == LogicalKeyboardKey.arrowRight &&
            key1 == LogicalKeyboardKey.arrowUp) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }
  }

  void _twoDirectionsWASDAndArrows(
      LogicalKeyboardKey key1, LogicalKeyboardKey key2) {
    if ((key1 == LogicalKeyboardKey.arrowRight ||
                key1 == LogicalKeyboardKey.keyD) &&
            (key2 == LogicalKeyboardKey.arrowDown ||
                key2 == LogicalKeyboardKey.keyS) ||
        (key2 == LogicalKeyboardKey.arrowRight ||
                key2 == LogicalKeyboardKey.keyD) &&
            (key1 == LogicalKeyboardKey.arrowDown ||
                key1 == LogicalKeyboardKey.keyS)) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if ((key1 == LogicalKeyboardKey.arrowLeft ||
                key1 == LogicalKeyboardKey.keyA) &&
            (key2 == LogicalKeyboardKey.arrowDown ||
                key2 == LogicalKeyboardKey.keyS) ||
        (key2 == LogicalKeyboardKey.arrowLeft ||
                key2 == LogicalKeyboardKey.keyA) &&
            (key1 == LogicalKeyboardKey.arrowDown ||
                key1 == LogicalKeyboardKey.keyS)) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if ((key1 == LogicalKeyboardKey.arrowLeft ||
                key1 == LogicalKeyboardKey.keyA) &&
            (key2 == LogicalKeyboardKey.arrowUp ||
                key2 == LogicalKeyboardKey.keyW) ||
        (key2 == LogicalKeyboardKey.arrowLeft ||
                key2 == LogicalKeyboardKey.keyA) &&
            (key1 == LogicalKeyboardKey.arrowUp ||
                key1 == LogicalKeyboardKey.keyW)) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if ((key1 == LogicalKeyboardKey.arrowRight ||
                key1 == LogicalKeyboardKey.keyD) &&
            (key2 == LogicalKeyboardKey.arrowUp ||
                key2 == LogicalKeyboardKey.keyW) ||
        (key2 == LogicalKeyboardKey.arrowRight ||
                key2 == LogicalKeyboardKey.keyD) &&
            (key1 == LogicalKeyboardKey.arrowUp ||
                key1 == LogicalKeyboardKey.keyW)) {
      joystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP_RIGHT,
          intensity: 1.0,
          radAngle: 0.0,
        ),
      );
    }
  }

  void resetDirectionalKeys() {
    _currentKeyboardKeys.clear();
  }
}
