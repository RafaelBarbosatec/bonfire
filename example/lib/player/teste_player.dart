import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class TestRotationPlayer extends RotationPlayer {
  double initSpeed = 150;
  TestRotationPlayer(Position position)
      : super(
            initPosition: position,
            animIdle: FlameAnimation.Animation.sequenced(
              "player/knight_idle_left.png",
              6,
              textureWidth: 16,
              textureHeight: 16,
            ),
            animRun: FlameAnimation.Animation.sequenced(
              "player/knight_run.png",
              6,
              textureWidth: 16,
              textureHeight: 16,
            ),
            speed: 150);

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    this.speed = initSpeed * event.intensity;
    super.joystickChangeDirectional(event);
  }

  @override
  void die() {
    remove();
    gameRef.addDecoration(
      GameDecoration(
        initPosition: Position(
          positionInWorld.left,
          positionInWorld.top,
        ),
        height: 30,
        width: 30,
        sprite: Sprite('player/crypt.png'),
      ),
    );
    super.die();
  }

  @override
  void joystickAction(int action) {
    if (action == 1) {
      actionAttackRange();
    }
    super.joystickAction(action);
  }

  void actionAttackRange() {
    gameRef.add(FlyingAttackAngleObject(
        initPosition: Position(positionInWorld.left, positionInWorld.top),
        radAngle: currentRadAngle,
        width: 25,
        height: 25,
        damage: 10,
        speed: initSpeed * 1.5,
        flyAnimation: FlameAnimation.Animation.sequenced(
          'player/fireball_top.png',
          3,
          textureWidth: 23,
          textureHeight: 23,
        ),
        destroyAnimation: FlameAnimation.Animation.sequenced(
          'player/explosion_fire.png',
          6,
          textureWidth: 32,
          textureHeight: 32,
        )));
  }
}
