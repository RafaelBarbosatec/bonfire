class LayerPriority {
  static const int BACKGROUND = 10;
  static const int MAP = 20;

  static int getPriorityFromMap(int priority) {
    return MAP + priority;
  }

  static int getPriorityLighting(int priority) {
    return priority + 1;
  }

  static int getPriorityColorFilter(int priority) {
    return priority + 2;
  }

  static int getPriorityInterface(int priority) {
    return priority + 3;
  }

  static int getPriorityJoystick(int priority) {
    return priority + 4;
  }
}
