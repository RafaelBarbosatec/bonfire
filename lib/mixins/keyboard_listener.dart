import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

mixin KeyboardEventListener on GameComponent {
  // If return 'true' this event is not relay to others components.
  bool onKeyboard(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    return false;
  }
}
