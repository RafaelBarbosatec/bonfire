import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/movement_v2.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 31/01/22
class ArmchairDecoration extends GameDecoration
    with BlockMovementCollision, MovementV2, Pushable {
  ArmchairDecoration(Vector2 position)
      : super.withSprite(
          position: position,
          size: Vector2.all(64),
          sprite: Sprite.load(
            'furniture.png',
            srcPosition: Vector2(192, 0),
            srcSize: Vector2.all(64),
          ),
        );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2.all(50),
        position: Vector2.all(7),
      ),
    );
    return super.onLoad();
  }
}
