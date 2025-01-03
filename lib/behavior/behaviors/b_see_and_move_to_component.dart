import 'package:bonfire/bonfire.dart';

class BSeeAndMoveToComponent extends Behavior {
  final GameComponent target;
  final double radiusVision;
  final double? visionAngle;
  final void Function(double dt, GameComponent target) onClose;
  final Behavior? doElseBehavior;
  final double distance;
  final MovementAxis movementAxis;

  BSeeAndMoveToComponent({
    required this.target,
    required this.onClose,
    this.radiusVision = 32,
    this.movementAxis = MovementAxis.all,
    this.visionAngle,
    this.doElseBehavior,
    this.distance = 5,
    super.id,
  });
  @override
  bool runAction(double dt, GameComponent comp, BonfireGameInterface game) {
    return BCanSee(
      target: target,
      radiusVision: radiusVision,
      visionAngle: visionAngle,
      doElseBehavior: BCustom(
        behavior: (dt, comp, game) {
          if (comp is Movement && doElseBehavior == null) {
            comp.stopMove();
          }
          return doElseBehavior?.runAction(dt, comp, game) ?? true;
        },
      ),
      doBehavior: (target) {
        return BCondition(
          condition: (_, comp, game) => comp.isCloseTo(
            target,
            distance: distance,
          ),
          doBehavior: BAction(
            action: (dt, comp, game) {
              if (comp is Movement) {
                comp.stopMove();
              }
              onClose(dt, comp);
            },
          ),
          doElseBehavior: BMoveToComponent(
            movementAxis: movementAxis,
            target: target,
            margin: distance,
          ),
        );
      },
    ).runAction(dt, comp, game);
  }
}
