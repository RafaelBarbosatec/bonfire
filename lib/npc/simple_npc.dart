import 'package:bonfire/npc/npc.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/direction_animations/simple_direction_animation.dart';
import 'package:bonfire/mixins/direction_animation.dart';
import 'package:flame/components.dart';

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
/// on 22/03/22

/// Enemy with animation in all direction
class SimpleNpc extends Npc with DirectionAnimation {
  SimpleNpc({
    required Vector2 position,
    required Vector2 size,
    SimpleDirectionAnimation? animation,
    double speed = 100,
    Direction initDirection = Direction.right,
  }) : super(
          position: position,
          size: size,
          speed: speed,
        ) {
    this.animation = animation;
    lastDirection = initDirection;
    lastDirectionHorizontal =
        initDirection == Direction.left ? Direction.left : Direction.right;
  }
}
