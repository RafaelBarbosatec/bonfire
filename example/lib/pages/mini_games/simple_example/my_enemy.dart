import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/enemy_sprite_sheet.dart';

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
/// on 19/10/21
class MyEnemy extends SimpleEnemy with BlockMovementCollision, RandomMovement {
  final bool withCollision;
  MyEnemy(Vector2 position, {this.withCollision = true})
      : super(
          animation: EnemySpriteSheet.simpleDirectionAnimation,
          position: position,
          size: Vector2.all(32),
        );

  @override
  Future<void> onLoad() {
    if (withCollision) {
      add(RectangleHitbox(size: size, isSolid: true));
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    runRandomMovement(dt);
  }
}
