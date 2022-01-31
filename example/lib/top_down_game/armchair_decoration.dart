import 'package:bonfire/bonfire.dart';

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
    with ObjectCollision, Movement, Pushable {
  ArmchairDecoration(Vector2 position)
      : super.withSprite(
          position: position,
          size: Vector2.all(64),
          sprite: Sprite.load(
            'furniture.png',
            srcPosition: Vector2(192, 0),
            srcSize: Vector2.all(64),
          ),
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(size: Vector2.all(50), align: Vector2.all(7)),
        ],
      ),
    );
  }
}
