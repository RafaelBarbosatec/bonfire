import 'package:bonfire/mixins/attackable.dart';
import 'package:bonfire/mixins/direction_animation.dart';
import 'package:bonfire/npc/ally/ally.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/direction_animations/simple_direction_animation.dart';
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
/// on 24/03/22

/// Enemy with animation in all direction
class SimpleAlly extends Ally with DirectionAnimation {
  SimpleAlly({
    required Vector2 position,
    required Vector2 size,
    SimpleDirectionAnimation? animation,
    double life = 100,
    double speed = 100,
    Direction initDirection = Direction.right,
    ReceivesAttackFromEnum receivesAttackFrom =
        ReceivesAttackFromEnum.PLAYER_AND_ALLY,
  }) : super(
          position: position,
          size: size,
          life: life,
          speed: speed,
          receivesAttackFrom: receivesAttackFrom,
        ) {
    this.animation = animation;
    lastDirection = initDirection;
    lastDirectionHorizontal =
        initDirection == Direction.left ? Direction.left : Direction.right;
  }
}
