import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/behavior/behavior.dart';
import 'package:bonfire/mixins/random_movement.dart';

class BRandomMovement extends Behavior {
  final double? speed;
  final double maxDistance;
  final double minDistance;
  final int timeKeepStopped;
  final bool checkDirectionWithRayCast;
  final bool updateAngle;
  final RandomMovementDirections allowDirections;

  BRandomMovement({
    this.speed,
    this.maxDistance = 50,
    this.minDistance = 25,
    this.timeKeepStopped = 2000,
    this.checkDirectionWithRayCast = false,
    this.updateAngle = false,
    this.allowDirections = RandomMovementDirections.all,
    super.id,
  });
  @override
  bool runAction(double dt, GameComponent comp, BonfireGameInterface game) {
    if (comp is RandomMovement) {
      comp.runRandomMovement(
        dt,
        speed: speed,
        maxDistance: maxDistance,
        minDistance: minDistance,
        checkDirectionWithRayCast: checkDirectionWithRayCast,
        timeKeepStopped: timeKeepStopped,
        updateAngle: updateAngle,
        directions: allowDirections,
      );
    }
    return true;
  }
}
