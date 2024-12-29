import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/direction_animation.dart';

class SimplePlayer extends Player with DirectionAnimation {
  SimplePlayer({
    required super.position,
    required super.size,
    SimpleDirectionAnimation? animation,
    Direction initDirection = Direction.right,
    super.speed,
    super.life,
  }) {
    this.animation = animation;
    lastDirection = initDirection;
    if (initDirection == Direction.left || initDirection == Direction.right) {
      lastDirectionHorizontal = initDirection;
    }
  }
}
