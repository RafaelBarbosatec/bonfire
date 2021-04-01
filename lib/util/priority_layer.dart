class LayerPriority {
  static const int BACKGROUND = 10;
  static const int MAP = 20;

  static int getPriorityFromMap(int priority) {
    return MAP + priority;
  }

  static int getPriorityLighting(int priority) {
    return priority + 10;
  }

  static int getPriorityColorFilter(int highestPriority) {
    return highestPriority + 5;
  }

  static int getPriorityInterface(int highestPriority) {
    return highestPriority + 10;
  }

  static int getPriorityJoystick(int highestPriority) {
    return highestPriority + 15;
  }
}
