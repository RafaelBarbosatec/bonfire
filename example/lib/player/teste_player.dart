import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class TestPlayer extends AnglePlayer {
  double initSpeed = 150;
  TestPlayer(Position position)
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
}
