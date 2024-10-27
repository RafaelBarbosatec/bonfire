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

  bool get isLeftSide => this == left || this == upLeft || this == downLeft;
  bool get isRightSide => this == right || this == upRight || this == downRight;

  bool get isUpSide => this == up || this == upRight || this == upLeft;
  bool get isDownSide => this == down || this == downRight || this == downLeft;

  bool isSameXDirection(double x) {
    if (x > 0 && (this == right || this == upRight || this == downRight)) {
      return true;
    }

    if (x < 0 && (this == left || this == upLeft || this == downLeft)) {
      return true;
    }
    return false;
  }

  bool isSameYDirection(double y) {
    if (y > 0 && (this == down || this == downRight || this == downLeft)) {
      return true;
    }

    if (y < 0 && (this == up || this == upRight || this == upLeft)) {
      return true;
    }
    return false;
  }

  factory Direction.fromName(String name) {
    return Direction.values.firstWhere(
      (e) => e.name == name,
      orElse: () => Direction.down,
    );
  }
}
