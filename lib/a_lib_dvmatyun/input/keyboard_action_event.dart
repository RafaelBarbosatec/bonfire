import 'package:bonfire/input/player_controller.dart';

// Class for keyboard events
class KeyboardActionEvent implements JoystickActionEvent {
  @override
  final dynamic id;
  @override
  final double intensity;
  @override
  final double radAngle;
  @override
  final ActionEvent event;

  @override
  final int logicalKeyboardKey;

  const KeyboardActionEvent({
    required this.event,
    required this.logicalKeyboardKey, // LogicalKeyboardKey.keyId
    this.intensity = 0.0,
    this.radAngle = 0.0,
    this.id,
  });
}
