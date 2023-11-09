import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision_game_component.dart';
import 'package:bonfire/util/controlled_update_animation.dart';

class TileWithCollision extends Tile {
  Iterable<ShapeHitbox>? collisions;
  TileWithCollision({
    required String spritePath,
    required Vector2 position,
    required Vector2 size,
    String? tileClass,
    this.collisions,
    double offsetX = 0,
    double offsetY = 0,
    Map<String, dynamic>? properties,
  }) : super(
          spritePath: spritePath,
          position: position,
          size: size,
          tileClass: tileClass,
          offsetX: offsetX,
          offsetY: offsetY,
          properties: properties,
        );

  TileWithCollision.fromSprite({
    required Sprite? sprite,
    required Vector2 position,
    required Vector2 size,
    String? tileClass,
    this.collisions,
    double offsetX = 0,
    double offsetY = 0,
    Color? color,
    Map<String, dynamic>? properties,
  }) : super.fromSprite(
          sprite: sprite,
          position: position,
          size: size,
          tileClass: tileClass,
          offsetX: offsetX,
          offsetY: offsetY,
          properties: properties,
          color: color,
        );

  TileWithCollision.withAnimation({
    required ControlledUpdateAnimation animation,
    required Vector2 position,
    required Vector2 size,
    String? tileClass,
    this.collisions,
    double offsetX = 0,
    double offsetY = 0,
    Map<String, dynamic>? properties,
  }) : super.fromAnimation(
          animation: animation,
          position: position,
          size: size,
          offsetX: offsetX,
          offsetY: offsetY,
          tileClass: tileClass,
          properties: properties,
        );

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
