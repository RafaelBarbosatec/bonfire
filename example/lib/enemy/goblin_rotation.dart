import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class GoblinRotation extends RotationEnemy {
  GoblinRotation(Position initPosition)
      : super(
          animIdle: FlameAnimation.Animation.sequenced(
            "enemy/goblin_idle.png",
            6,
            textureWidth: 16,
            textureHeight: 16,
          ),
          animRun: FlameAnimation.Animation.sequenced(
            "enemy/goblin_run_left.png",
            6,
            textureWidth: 16,
            textureHeight: 16,
          ),
          initPosition: initPosition,
          width: 25,
          height: 25,
        );

  @override
  void update(double dt) {
    this.seeAndMoveToPlayer(
      closePlayer: (player) {},
      visionCells: 4,
    );
    super.update(dt);
  }
}
