// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  IDLE;

  bool get isLeft =>
      this == MOVE_LEFT || this == MOVE_DOWN_LEFT || this == MOVE_UP_LEFT;
  bool get isRight =>
      this == MOVE_RIGHT || this == MOVE_DOWN_RIGHT || this == MOVE_UP_RIGHT;
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

  JoystickDirectionalEvent copyWith({
    JoystickMoveDirectional? directional,
    double? intensity,
    double? radAngle,
    bool? isKeyboard,
  }) {
    return JoystickDirectionalEvent(
      directional: directional ?? this.directional,
      intensity: intensity ?? this.intensity,
      radAngle: radAngle ?? this.radAngle,
      isKeyboard: isKeyboard ?? this.isKeyboard,
    );
  }
}

enum ActionEvent { DOWN, UP, MOVE }

class JoystickActionEvent {
  final dynamic id;
  final double intensity;
  final double radAngle;
  final ActionEvent event;

  JoystickActionEvent({
    required this.event,
    this.id,
    this.intensity = 0.0,
    this.radAngle = 0.0,
  });
}

mixin PlayerControllerListener {
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {}
  void onJoystickAction(JoystickActionEvent event) {}
}

abstract class PlayerController extends GameComponent
    with PlayerControllerListener {
  final dynamic id;
  final List<PlayerControllerListener> _observers = [];

  PlayerController({this.id, PlayerControllerListener? observer}) {
    if (observer != null) {
      _observers.add(observer);
    }
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    for (final o in _observers) {
      o.onJoystickChangeDirectional(event);
    }
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    for (final o in _observers) {
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

  bool get containObservers => _observers.isNotEmpty;

  @override
  int get priority {
    return LayerPriority.getHudJoystickPriority();
  }

  @override
  bool get isVisible => true;

  @override
  bool hasGesture() => true;
}
