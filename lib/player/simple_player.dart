import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/direction_animation.dart';

class SimplePlayer extends Player with DirectionAnimation {
  SimplePlayer({
    required Vector2 position,
    required Vector2 size,
    SimpleDirectionAnimation? animation,
    Direction initDirection = Direction.right,
    double speed = 150,
    double life = 100,
  }) : super(
          position: position,
          size: size,
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
