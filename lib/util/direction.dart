enum Direction {
  left,
  right,
  up,
  down,
  upLeft,
  upRight,
  downLeft,
  downRight;

  bool get isVertical => this == down || this == up;
  bool get isHorizontal => this == left || this == right;

  bool isSameXDirection(double x) {
    if (x > 0 && this == right) {
      return true;
    }

    if (x < 0 && this == left) {
      return true;
    }
    return false;
  }

  bool isSameYDirection(double y) {
    if (y > 0 && this == down) {
      return true;
    }

    if (y < 0 && this == up) {
      return true;
    }
    return false;
  }
}
