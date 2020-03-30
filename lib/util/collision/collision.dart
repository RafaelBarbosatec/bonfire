enum CollisionAlign {
  BOTTOM_CENTER,
  CENTER,
  TOP_CENTER,
  LEFT_CENTER,
  RIGHT_CENTER,
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
}

class Collision {
  final double height;
  final double width;
  final CollisionAlign align;

  Collision(
      {this.height = 0.0,
      this.width = 0.0,
      this.align = CollisionAlign.BOTTOM_CENTER});
}
