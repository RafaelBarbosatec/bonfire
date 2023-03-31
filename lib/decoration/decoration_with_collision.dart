import 'package:bonfire/bonfire.dart';

/// GameDecoration with collision used in construct of the map with Tiled
class GameDecorationWithCollision extends GameDecoration
    with BlockMovementCollision {
  Iterable<ShapeComponent>? collisions;
  GameDecorationWithCollision({
    required Vector2 position,
    required Vector2 size,
    Sprite? sprite,
    SpriteAnimation? animation,
    this.collisions,
    double offsetX = 0,
    double offsetY = 0,
    bool aboveComponents = false,
  }) : super(
          position: position,
          size: size,
          animation: animation,
          sprite: sprite,
        ) {
    this.aboveComponents = aboveComponents;
  }

  GameDecorationWithCollision.withSprite({
    required Future<Sprite> sprite,
    required Vector2 position,
    required Vector2 size,
    this.collisions,
    double offsetX = 0,
    double offsetY = 0,
    bool aboveComponents = false,
  }) : super.withSprite(
          sprite: sprite,
          position: position,
          size: size,
        ) {
    this.aboveComponents = aboveComponents;
  }

  GameDecorationWithCollision.withAnimation({
    required Future<SpriteAnimation> animation,
    required Vector2 position,
    required Vector2 size,
    this.collisions,
    double offsetX = 0,
    double offsetY = 0,
    bool aboveComponents = false,
  }) : super.withAnimation(
          animation: animation,
          position: position,
          size: size,
        ) {
    this.aboveComponents = aboveComponents;
  }

  @override
  Future<void> onLoad() {
    collisions?.let(addAll);
    return super.onLoad();
  }
}
