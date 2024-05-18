import 'package:flutter/services.dart';

class KeyboardDirectionalKeys {
  final LogicalKeyboardKey up;
  final LogicalKeyboardKey down;
  final LogicalKeyboardKey left;
  final LogicalKeyboardKey right;

  KeyboardDirectionalKeys({
    required this.up,
    required this.down,
    required this.left,
    required this.right,
  });

  List<LogicalKeyboardKey> get keys => [up, down, left, right];

  bool contain(LogicalKeyboardKey key) => keys.contains(key);

  factory KeyboardDirectionalKeys.arrows() {
    return KeyboardDirectionalKeys(
      down: LogicalKeyboardKey.arrowDown,
      up: LogicalKeyboardKey.arrowUp,
      left: LogicalKeyboardKey.arrowLeft,
      right: LogicalKeyboardKey.arrowRight,
    );
  }

  factory KeyboardDirectionalKeys.wasd() {
    return KeyboardDirectionalKeys(
      down: LogicalKeyboardKey.keyS,
      up: LogicalKeyboardKey.keyW,
      left: LogicalKeyboardKey.keyA,
      right: LogicalKeyboardKey.keyD,
    );
  }
}

class KeyboardConfig {
  /// Use to enable ou disable keyboard events
  bool enable;

  /// Type of the directional (arrows, wasd or wasdAndArrows)
  final List<KeyboardDirectionalKeys> directionalKeys;

  /// You can pass specific Keys accepted. If null accept all keys
  final List<LogicalKeyboardKey>? acceptedKeys;

  /// Use to enable diagonal input events
  bool enableDiagonalInput;

  KeyboardConfig({
    this.enable = true,
    List<KeyboardDirectionalKeys>? directionalKeys,
    this.acceptedKeys,
    this.enableDiagonalInput = true,
  }) : directionalKeys = directionalKeys ?? [KeyboardDirectionalKeys.arrows()] {
    acceptedKeys?.addAll(
      this.directionalKeys.map((e) => e.keys).expand((e) => e),
    );
  }
}
