import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

export 'package:bonfire/input/keyboard/keyboard_config.dart';

class Keyboard extends PlayerController with KeyboardEventListener {
  bool _directionalIsIdle = false;

  final KeyboardConfig keyboardConfig;

  /// Class responsible to adds a keyboard controller in your game.
  /// If pass [oberver] this param, the joystick will controll this observer and not the Component passed in `player` param.
  Keyboard({
    super.id,
    KeyboardConfig? config,
    PlayerControllerListener? observer,
  }) : keyboardConfig = config ?? KeyboardConfig() {
    if (observer != null) {
      addObserver(observer);
    }
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    /// If the keyboard is disabled, we do not process the event
    if (!keyboardConfig.enable) {
      return false;
    }

    /// If the key is not accepted, we do not process the event
    if (keyboardConfig.acceptedKeys != null) {
      if (!keyboardConfig.acceptedKeys!.contains(event.logicalKey)) {
        return false;
      }
    }

    /// No keyboard events, keep idle
    if (!_containDirectionalPressed(keysPressed) &&
        !event.synthesized &&
        !_directionalIsIdle) {
      _directionalIsIdle = true;
      onJoystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.IDLE,
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
      if (event is KeyDownEvent) {
        onJoystickAction(
          JoystickActionEvent(
            id: event.logicalKey,
            event: ActionEvent.DOWN,
          ),
        );
      } else if (event is KeyUpEvent) {
        onJoystickAction(
          JoystickActionEvent(
            id: event.logicalKey,
            event: ActionEvent.UP,
          ),
        );
      }
    }

    return true;
  }

  /// Check if the key is for directional [arrows, wasd, or both]
  bool _isDirectional(LogicalKeyboardKey key) {
    return keyboardConfig.directionalKeys.any(
      (element) => element.contain(key),
    );
  }

  bool isUpPressed(LogicalKeyboardKey key) {
    return keyboardConfig.directionalKeys.any((element) => element.up == key);
  }

  bool isDownPressed(LogicalKeyboardKey key) {
    return keyboardConfig.directionalKeys.any((element) => element.down == key);
  }

  bool isLeftPressed(LogicalKeyboardKey key) {
    return keyboardConfig.directionalKeys.any((element) => element.left == key);
  }

  bool isRightPressed(LogicalKeyboardKey key) {
    return keyboardConfig.directionalKeys
        .any((element) => element.right == key);
  }

  void _sendOneDirection(LogicalKeyboardKey key) {
    if (isUpPressed(key)) {
      onJoystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP,
          intensity: 1.0,
          isKeyboard: true,
        ),
      );
    }
    if (isDownPressed(key)) {
      onJoystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN,
          intensity: 1.0,
          isKeyboard: true,
        ),
      );
    }

    if (isLeftPressed(key)) {
      onJoystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_LEFT,
          intensity: 1.0,
          isKeyboard: true,
        ),
      );
    }

    if (isRightPressed(key)) {
      onJoystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_RIGHT,
          intensity: 1.0,
          isKeyboard: true,
        ),
      );
    }
  }

  void _sendTwoDirection(LogicalKeyboardKey key1, LogicalKeyboardKey key2) {
    if (isRightPressed(key1) && isDownPressed(key2) ||
        isDownPressed(key1) && isRightPressed(key2)) {
      onJoystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN_RIGHT,
          intensity: 1.0,
          isKeyboard: true,
        ),
      );
    }

    if (isLeftPressed(key1) && isDownPressed(key2) ||
        isDownPressed(key1) && isLeftPressed(key2)) {
      onJoystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN_LEFT,
          intensity: 1.0,
          isKeyboard: true,
        ),
      );
    }

    if (isLeftPressed(key1) && isUpPressed(key2) ||
        isUpPressed(key1) && isLeftPressed(key2)) {
      onJoystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP_LEFT,
          intensity: 1.0,
          isKeyboard: true,
        ),
      );
    }

    if (isRightPressed(key1) && isUpPressed(key2) ||
        isUpPressed(key1) && isRightPressed(key2)) {
      onJoystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP_RIGHT,
          intensity: 1.0,
          isKeyboard: true,
        ),
      );
    }
  }

  bool _containDirectionalPressed(Set<LogicalKeyboardKey> keysPressed) {
    for (final element in keysPressed) {
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
