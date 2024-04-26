import 'package:bonfire/bonfire.dart';

export 'rotation_ally.dart';
export 'simple_ally.dart';

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
class Ally extends Npc with Attackable {
  Ally({
    required Vector2 position,
    required Vector2 size,
    double life = 10,
    double speed = 100,
    AcceptableAttackOriginEnum receivesAttackFrom =
        AcceptableAttackOriginEnum.ENEMY,
  }) : super(position: position, size: size, speed: speed) {
    this.speed = speed;
    this.receivesAttackFrom = receivesAttackFrom;
    initialLife(life);
    this.position = position;
    this.size = size;
  }
}
