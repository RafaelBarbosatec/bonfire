import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/person_sprite_sheet.dart';

class RageEnemy extends SimpleEnemy {
  RageEnemy({
    required Vector2 position,
  }) : super(
          position: position,
          animation: PersionSpritesheet().simpleAnimarion(),
          size: Vector2.all(24),
          speed: 25,
        );

  @override
  void update(double dt) {
    seeAndMoveToAttackRange();
    super.update(dt);
  }

  @override
  Future<void> onLoad() {
    /// Adds rectangle collision
    add(RectangleHitbox(size: size / 2, position: size / 4));
    return super.onLoad();
  }
}
