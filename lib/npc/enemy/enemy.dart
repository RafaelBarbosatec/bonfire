import 'package:bonfire/mixins/life/life.dart';
import 'package:bonfire/npc/npc.dart';

export 'platform_enemy.dart';
export 'rotation_enemy.dart';
export 'simple_enemy.dart';

/// It is used to represent your enemies.
class Enemy extends Npc with WithLife {
  Enemy({
    required super.position,
    required super.size,
    double life = 10,
    super.speed,
    AcceptableAttackOriginEnum receivesAttackFrom =
        AcceptableAttackOriginEnum.PLAYER_AND_ALLY,
  }) {
    this.life.receivesAttackFrom = receivesAttackFrom;
    this.life.initial(life);
  }
}
