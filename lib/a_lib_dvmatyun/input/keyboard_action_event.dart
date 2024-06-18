import 'package:bonfire/input/player_controller.dart';
import 'package:flutter/services.dart';

class KeyboardActionEvent implements JoystickActionEvent {
  @override
  dynamic get id => logicalKey;
  @override
  final double intensity;
  @override
  final double radAngle;
  @override
  final ActionEvent event;
  @override
  final LogicalKeyboardKey? logicalKey;

  const KeyboardActionEvent({
    required this.event,
    required this.logicalKey,
    this.intensity = 0.0,
    this.radAngle = 0.0,
  });
  
}