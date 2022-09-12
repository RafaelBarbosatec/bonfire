import 'package:bonfire/npc/npc.dart';
import 'package:bonfire/mixins/attackable.dart';
import 'package:flame/components.dart';

export 'rotation_enemy.dart';
export 'simple_enemy.dart';

/// It is used to represent your enemies.
class Enemy extends Npc with Attackable {
  Enemy({
    required Vector2 position,
    required Vector2 size,
    double life = 10,
    double speed = 100,
    ReceivesAttackFromEnum receivesAttackFrom =
        ReceivesAttackFromEnum.PLAYER_AND_ALLY,
  }) : super(position: position, size: size, speed: speed) {
    this.speed = speed;
    this.receivesAttackFrom = receivesAttackFrom;
    initialLife(life);
    this.position = position;
    this.size = size;
  }
}
