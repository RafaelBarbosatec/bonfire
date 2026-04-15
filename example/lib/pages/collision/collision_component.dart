import 'package:bonfire/bonfire.dart';

class CollisionComponent extends GameDecoration
    with Movement, BlockMovementCollision, HandleForces, ElasticCollision {
  final bool isCircle;
  CollisionComponent({
    required Vector2 position,
    required this.isCircle,
  }) : super(position: position, size: Vector2.all(16)) {
    addForce(GravityForce2D());
  }

  @override
  void render(Canvas canvas) {
    if (isCircle) {
      canvas.drawCircle(Offset(width / 2, height / 2), width / 2, paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    }

    super.render(canvas);
  }

  @override
  Future<void> onLoad() {
    if (isCircle) {
      add(CircleHitbox(
        radius: width / 2,
        isSolid: true,
      ));
    } else {
      add(RectangleHitbox(
        size: size,
        isSolid: true,
      ));
    }

    return super.onLoad();
  }
}
