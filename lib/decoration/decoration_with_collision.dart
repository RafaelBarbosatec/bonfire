import 'package:bonfire/bonfire.dart';

/// GameDecoration with collision used in construct of the map with Tiled
class GameDecorationWithCollision extends GameDecoration {
  Iterable<ShapeHitbox>? collisions;
  GameDecorationWithCollision({
    required super.position,
    required super.size,
    super.sprite,
    super.animation,
    this.collisions,
    super.renderAboveComponents,
  });

  GameDecorationWithCollision.withSprite({
    required Future<Sprite> super.sprite,
    required super.position,
    required super.size,
    this.collisions,
    super.renderAboveComponents,
  }) : super.withSprite();

  GameDecorationWithCollision.withAnimation({
    required Future<SpriteAnimation> super.animation,
    required super.position,
    required super.size,
    this.collisions,
    super.renderAboveComponents,
  }) : super.withAnimation();

  @override
  Future<void> onLoad() {
    collisions?.let(addAll);
    return super.onLoad();
  }
}
