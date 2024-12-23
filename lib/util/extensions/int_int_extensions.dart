extension IntIntExtensions on (int, int) {
  int get x => $1;
  int get y => $2;

  bool isNeighbour((int, int) other, {bool withDiagonal = true}) {
    if (this == other) {
      return false;
    }

    if (withDiagonal) {
      return (x - other.x).abs() <= 1 && (y - other.y).abs() <= 1;
    }

    return (x - other.x).abs() <= 1 && y == other.y ||
        x == other.x && (y - other.y).abs() <= 1;
  }
}
