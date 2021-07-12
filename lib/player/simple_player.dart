import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/direction_animations/simple_direction_animation.dart';
import 'package:bonfire/util/mixins/direction_animation.dart';

class SimplePlayer extends Player with DirectionAnimation {
  SimplePlayer({
    required Vector2 position,
    required SimpleDirectionAnimation animation,
    Direction initDirection = Direction.right,
    double speed = 150,
    double width = 32,
    double height = 32,
    double life = 100,
  }) : super(
          position: position,
          width: width,
          height: height,
          life: life,
          speed: speed,
        ) {
    this.animation = animation;
    lastDirection = initDirection;
    if (initDirection == Direction.left || initDirection == Direction.right) {
      lastDirectionHorizontal = initDirection;
    }
  }
}
