enum CollisionAlign { BOTTOM_CENTER, CENTER, TOP_CENTER }

class Collision {
  final double height;
  final double width;
  final CollisionAlign align;

  Collision(
      {this.height = 0.0,
      this.width = 0.0,
      this.align = CollisionAlign.BOTTOM_CENTER});
}
