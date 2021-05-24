class LayerPriority {
  static const int BACKGROUND = 10;
  static const int MAP = 20;
  static const int COMPONENTS = 30;

  static int getComponentPriority(int bottom) {
    return COMPONENTS + bottom;
  }

  static int getAbovePriority(int highestPriority) {
    return highestPriority + 5;
  }

  static int getLightingPriority(int highestPriority) {
    return highestPriority + 10;
  }

  static int getColorFilterPriority(int highestPriority) {
    return highestPriority + 20;
  }

  static int getInterfacePriority(int highestPriority) {
    return highestPriority + 30;
  }

  static int getJoystickPriority(int highestPriority) {
    return highestPriority + 40;
  }
}
