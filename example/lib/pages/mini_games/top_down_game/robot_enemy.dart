import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';

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
/// on 28/01/22
class ZombieEnemy extends RotationEnemy
    with BlockMovementCollision, RandomMovement {
  ZombieEnemy(Vector2 position)
      : super(
          position: position,
          size: Vector2(68, 43),
          animIdle: _getAnimation(),
          animRun: _getAnimation(),
        );

  static Future<SpriteAnimation> _getAnimation() {
    return Sprite.load('zombie.png').toAnimation();
  }

  @override
  void update(double dt) {
    super.update(dt);
    seeAndMoveToPlayer(
      closePlayer: (_) {
        simpleAttackMelee(
          damage: 10,
          size: Vector2.all(size.y),
          animationRight: CommonSpriteSheet.blackAttackEffectRight,
        );
      },
      radiusVision: 128,
      notObserved: () {
        runRandomMovement(
          dt,
          updateAngle: true,
          maxDistance: 64,
          minDistance: 32,
          speed: 20,
        );
        return false;
      },
    );
  }

  @override
  void onDie() {
    gameRef.add(
      AnimatedGameObject(
        animation: CommonSpriteSheet.smokeExplosion,
        position: position,
        size: Vector2.all(size.x),
        anchor: anchor,
        loop: false,
      ),
    );
    gameRef.camera.shake(intensity: 4);
    removeFromParent();
    super.onDie();
  }

  @override
  Future<void> onLoad() {
    add(
      CircleHitbox(
        radius: size.y / 2,
        position: Vector2(
          12.5,
          0,
        ),
      ),
    );
    return super.onLoad();
  }
}
