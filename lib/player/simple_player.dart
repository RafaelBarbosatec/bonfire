import 'package:bonfire/bonfire.dart';

class SimplePlayer extends Player with WithDirectionAnimation {
  SimplePlayer({
    required super.position,
    required super.size,
    SimpleDirectionAnimation? animation,
    Direction initDirection = Direction.right,
    super.speed,
    super.life,
  }) {
    this.animation = animation;
    direction = initDirection;
  }
}
