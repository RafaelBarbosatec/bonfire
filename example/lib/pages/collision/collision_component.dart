import 'package:bonfire/bonfire.dart';

class CollisionComponent extends GameDecoration
    with Movement, SimpleCollision, Forces, SimpleElasticCollision {
  final bool isCircle;

  CollisionComponent({
    required Vector2 position,
    required this.isCircle,
  }) : super(position: position, size: Vector2.all(16)) {
    // Gravidade mais moderada para testar melhor
    setGravity(Vector2(0, 400)); // Reduzida de 600 para 400

    // Configurar comportamento elástico - AGORA com valores físicos corretos
    setupElasticCollision(
      enabled: true,
      bounciness: 0.85, // Valor físicamente realístico
      minBounceVelocity: 20.0,
    );

    // Configurar física com menos resistência
    setupPhysics(
      friction: Vector2(0.05, 0.05), // Fricção muito baixa
      dragCoefficient: 0.01, // Resistência mínima
    );
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
