import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision_game_component.dart';

class TileWithCollision extends TileComponent {
  Iterable<ShapeHitbox>? collisions;
  TileWithCollision({
    required super.spritePath,
    required super.position,
    required super.size,
    super.tileClass,
    this.collisions,
    super.offsetX,
    super.offsetY,
    super.properties,
  });

  TileWithCollision.fromSprite({
    required super.sprite,
    required super.position,
    required super.size,
    super.tileClass,
    this.collisions,
    super.offsetX,
    super.offsetY,
    super.color,
    super.properties,
  }) : super.fromSprite();

  TileWithCollision.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
    super.tileClass,
    this.collisions,
    super.offsetX,
    super.offsetY,
    super.properties,
  }) : super.fromAnimation();

  @override
  Future<void> onLoad() {
    collisions?.let(addAll);
    return super.onLoad();
  }

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    if (other is TileWithCollision ||
        other is GameDecorationWithCollision ||
        other is CollisionMapComponent) {
      return false;
    }
    return super.onComponentTypeCheck(other);
  }
}
