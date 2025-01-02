import 'package:bonfire/behavior/behavior.dart';
import 'package:bonfire/bonfire.dart';

class BMoveToComponent extends Behavior {
  final GameComponent target;
  final double margin;
  final MovementAxis movementAxis;

  BMoveToComponent({
    required this.target,
    dynamic id,
    this.margin = 0,
    this.movementAxis = MovementAxis.all,
  }) : super(id);

  @override
  bool runAction(double dt, GameComponent comp, BonfireGameInterface game) {
    if (comp is Movement) {
      return comp.moveTowardsTarget(
        target: target,
        margin: margin,
        movementAxis: movementAxis,
      );
    } else {
      return false;
    }
  }
}
