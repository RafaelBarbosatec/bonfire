import 'package:bonfire/bonfire.dart';

export 'platform_player.dart';
export 'rotation_player.dart';
export 'simple_player.dart';

class Player extends GameComponent
    with
        Movement,
        WithLife,
        Vision,
        PlayerControllerListener,
        MovementByJoystick {
  Player({
    required Vector2 position,
    required Vector2 size,
    double life = 100,
    double? speed,
  }) {
    this.speed = speed ?? this.speed;
    this.life.receivesAttackFrom = AcceptableAttackOriginEnum.ENEMY;
    this.life.initial(life);
    this.position = position;
    this.size = size;
  }
}
