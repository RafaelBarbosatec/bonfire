import 'package:bonfire/mixins/direction_animation.dart';
import 'package:bonfire/npc/npc.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/direction_animations/simple_direction_animation.dart';

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
    required super.position,
    required super.size,
    SimpleDirectionAnimation? animation,
    super.speed,
    Direction initDirection = Direction.right,
  }) {
    this.animation = animation;
    lastDirection = initDirection;
    lastDirectionHorizontal =
        initDirection == Direction.left ? Direction.left : Direction.right;
  }
}
