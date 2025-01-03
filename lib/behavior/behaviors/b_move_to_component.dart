import 'package:bonfire/bonfire.dart';

class BMoveToComponent extends Behavior {
  final GameComponent target;
  final double margin;
  final MovementAxis movementAxis;

  BMoveToComponent({
    required this.target,
    super.id,
    this.margin = 0,
    this.movementAxis = MovementAxis.all,
  });

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
