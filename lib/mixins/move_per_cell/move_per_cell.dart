import 'package:bonfire/bonfire.dart';

export 'move_per_cell_api.dart';

/// Mixin that restricts component movement to discrete cells.
///
/// The component must have a [Movement] mixin.
///
/// Access all per-cell functionality through the [movePerCell] API.
mixin WithMovePerCell on Movement {
  late final MovePerCellApi movePerCell = MovePerCellApi(this);

  @override
  void update(double dt) {
    movePerCell.update(dt);
    super.update(dt);
  }

  @override
  void moveLeft({double? speed, bool resetCrossAxis = false}) {
    movePerCell.moveLeft(speed: speed, resetCrossAxis: resetCrossAxis);
  }

  @override
  void moveRight({double? speed, bool resetCrossAxis = false}) {
    movePerCell.moveRight(speed: speed, resetCrossAxis: resetCrossAxis);
  }

  @override
  void moveDown({double? speed, bool resetCrossAxis = false}) {
    movePerCell.moveDown(speed: speed, resetCrossAxis: resetCrossAxis);
  }

  @override
  void moveUp({double? speed, bool resetCrossAxis = false}) {
    movePerCell.moveUp(speed: speed, resetCrossAxis: resetCrossAxis);
  }

  @override
  void moveByAngle(double angle, {double? speed}) {
    movePerCell.moveByAngle(angle, speed: speed);
  }

  @override
  void onGameMounted() {
    if (this is MovementByJoystick) {
      (this as MovementByJoystick).setupMovementByJoystick(
        startOnIdle: false,
        diagonalEnabled: false,
      );
    }
    super.onGameMounted();
  }
}
