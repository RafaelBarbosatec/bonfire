import 'package:bonfire/mixins/direction_animation.dart';
import 'package:bonfire/npc/ally/ally.dart';
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
/// on 24/03/22

/// Enemy with animation in all direction
class SimpleAlly extends Ally with DirectionAnimation {
  SimpleAlly({
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
