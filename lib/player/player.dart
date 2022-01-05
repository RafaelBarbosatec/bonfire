import 'package:bonfire/bonfire.dart';

class Player extends GameComponent
    with
        Movement,
        Attackable,
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
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    var newAngle = event.radAngle;
    if (dPadAngles || newAngle == 0.0) {
      newAngle = event.directionalRadAngle;
    }
    if (event.directional != JoystickMoveDirectional.IDLE &&
        !isDead &&
        newAngle != 0.0) {
      movementRadAngle = newAngle;
    }
    super.joystickChangeDirectional(
      JoystickDirectionalEvent(
        directional: event.directional,
        intensity: event.intensity,
        radAngle: newAngle,
      ),
    );
  }

  @override
  void joystickAction(JoystickActionEvent event) {}

  @override
  void moveTo(Vector2 position) {
    this.moveToPositionAlongThePath(position);
  }
}
