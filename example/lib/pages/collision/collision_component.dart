import 'package:bonfire/bonfire.dart';

class CollisionComponent extends GameDecoration
    with Movement, SimpleCollision, Forces, SimpleElasticCollision {
  final bool isCircle;
  CollisionComponent({
    required Vector2 position,
    required this.isCircle,
  }) : super(position: position, size: Vector2.all(16)) {
    // Configurar física realista para estabilização
    setupElasticCollision(
      bounciness:
          0.75, // restitution = 0.75 * 1.0 = 0.75 (como bola de basquete)
      minBounceVelocity: 20.0, // velocidade mínima para bounce (pixels/s)
    );

    // Configurar fricção para amortecimento
    setupPhysics(
      friction: Vector2(0.3, 0.3), // fricção horizontal e vertical
      dragCoefficient:
          0.02, // resistência do ar reduzida para não interferir na gravidade
      mass: 1.0, // massa padrão
    );

    // Gravidade mais forte para ser mais perceptível
    setGravity(Vector2(0, 600)); // 600 pixels/s² (mais realista visualmente)
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
