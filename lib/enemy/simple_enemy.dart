import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/direction_animations/simple_direction_animation.dart';
import 'package:bonfire/util/mixins/direction_animation.dart';
import 'package:flame/components.dart';

/// Enemy with animation in all direction
class SimpleEnemy extends Enemy with DirectionAnimation {
  SimpleEnemy({
    required Vector2 position,
    required Vector2 size,
    required SimpleDirectionAnimation animation,
    double life = 100,
    double speed = 100,
    Direction initDirection = Direction.right,
  }) : super(
          position: position,
          size: size,
          life: life,
          speed: speed,
        ) {
    this.animation = animation;
    lastDirection = initDirection;
    lastDirectionHorizontal =
        initDirection == Direction.left ? Direction.left : Direction.right;
  }
}
