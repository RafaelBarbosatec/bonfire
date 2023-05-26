import 'package:bonfire/bonfire.dart';

export 'platform_player.dart';
export 'rotation_player.dart';
export 'simple_player.dart';

class Player extends GameComponent
    with
        Movement,
        Attackable,
        Vision,
        MoveToPositionAlongThePath,
        JoystickListener,
        MovementByJoystick {
  Player({
    required Vector2 position,
    required Vector2 size,
    double life = 100,
    double speed = 100,
  }) {
    this.speed = speed;
    receivesAttackFrom = ReceivesAttackFromEnum.ENEMY;
    initialLife(life);
    this.position = position;
    this.size = size;
  }

  @override
  void moveTo(Vector2 position) {
    moveToPositionAlongThePath(position);
  }
}
