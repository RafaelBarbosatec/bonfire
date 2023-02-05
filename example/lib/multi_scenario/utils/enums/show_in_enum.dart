import 'package:bonfire/util/direction.dart';

enum ShowInEnum {
  left,
  right,
  top,
  bottom,
}

extension ShowInEnumExtension on ShowInEnum {
  Direction get direction {
    switch (this) {
      case ShowInEnum.right:
        return Direction.left;
      case ShowInEnum.left:
      case ShowInEnum.top:
      case ShowInEnum.bottom:
        return Direction.right;
      default:
        return Direction.right;
    }
  }
}
