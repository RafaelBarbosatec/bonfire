import 'package:bonfire/mixins/direction_animation.dart';
import 'package:bonfire/npc/enemy/enemy.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/direction_animations/simple_direction_animation.dart';

/// Enemy with animation in all direction
class SimpleEnemy extends Enemy with DirectionAnimation {
  SimpleEnemy({
    required super.position,
    required super.size,
    SimpleDirectionAnimation? animation,
    super.life = 100,
    super.speed,
    Direction initDirection = Direction.right,
    super.receivesAttackFrom,
  }) {
    this.animation = animation;
    lastDirection = initDirection;
    lastDirectionHorizontal =
        initDirection == Direction.left ? Direction.left : Direction.right;
  }
}
