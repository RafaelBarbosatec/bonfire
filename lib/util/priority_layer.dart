// ignore_for_file: constant_identifier_names

class LayerPriority {
  static const int BACKGROUND = 10;
  static const int MAP = 20;
  static const int _COMPONENTS = 30;

  static int getComponentPriority(int bottom) {
    return _COMPONENTS + bottom;
  }

  static int getAbovePriority(int highestPriority) {
    return highestPriority + 10;
  }

  static int getHudLightingPriority() {
    return 10;
  }

  static int getHudColorFilterPriority() {
    return 20;
  }

  static int getHudInterfacePriority() {
    return 30;
  }

  static int getHudJoystickPriority() {
    return 40;
  }
}
