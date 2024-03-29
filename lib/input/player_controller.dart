// ignore_for_file: constant_identifier_names

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/priority_layer.dart';

enum JoystickMoveDirectional {
  MOVE_UP,
  MOVE_UP_LEFT,
  MOVE_UP_RIGHT,
  MOVE_RIGHT,
  MOVE_DOWN,
  MOVE_DOWN_RIGHT,
  MOVE_DOWN_LEFT,
  MOVE_LEFT,
  IDLE
}

class JoystickDirectionalEvent {
  final JoystickMoveDirectional directional;
  final double intensity;
  final double radAngle;
  final bool isKeyboard;

  JoystickDirectionalEvent({
    required this.directional,
    this.intensity = 0.0,
    this.radAngle = 0.0,
    this.isKeyboard = false,
  });
}

enum ActionEvent { DOWN, UP, MOVE }

class JoystickActionEvent {
  final dynamic id;
  final double intensity;
  final double radAngle;
  final ActionEvent event;

  JoystickActionEvent({
    this.id,
    this.intensity = 0.0,
    this.radAngle = 0.0,
    required this.event,
  });
}

mixin PlayerControllerListener {
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {}
  void onJoystickAction(JoystickActionEvent event) {}
}

abstract class PlayerController extends GameComponent {
  final dynamic id;
  final List<PlayerControllerListener> _observers = [];

  PlayerController({this.id, PlayerControllerListener? observer}) {
    if (observer != null) {
      _observers.add(observer);
    }
  }

  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    for (var o in _observers) {
      o.onJoystickChangeDirectional(event);
    }
  }

  void joystickAction(JoystickActionEvent event) {
    for (var o in _observers) {
      o.onJoystickAction(event);
    }
  }

  void addObserver(PlayerControllerListener listener) {
    _observers.add(listener);
  }

  void removeObserver(PlayerControllerListener listener) {
    _observers.remove(listener);
  }

  void cleanObservers() {
    _observers.clear();
  }

  bool containObserver(PlayerControllerListener listener) {
    return _observers.contains(listener);
  }

  @override
  int get priority {
    return LayerPriority.getHudJoystickPriority();
  }

  @override
  bool get enabledCheckIsVisible => false;

  @override
  bool get isVisible => true;

  @override
  bool hasGesture() => true;
}
