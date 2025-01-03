import 'package:bonfire/bonfire.dart';

class BCanSeeType<T extends GameComponent> extends Behavior {
  final double radiusVision;
  final double? visionAngle;
  final double angle;
  final Behavior Function(List<T> list) doBehavior;
  final Behavior? doElseBehavior;

  BCanSeeType({
    required this.doBehavior,
    this.radiusVision = 32,
    this.visionAngle,
    this.angle = 3.14159,
    this.doElseBehavior,
  });

  @override
  bool runAction(double dt, GameComponent comp, BonfireGameInterface game) {
    if (comp is Vision) {
      List<T>? list;
      comp.seeComponentType<T>(
        radiusVision: radiusVision,
        visionAngle: visionAngle,
        angle: angle,
        observed: (c) {
          list = c;
        },
      );
      if (list != null) {
        return doBehavior(list!).runAction(dt, comp, game);
      }
      return doElseBehavior?.runAction(dt, comp, game) ?? true;
    } else {
      return true;
    }
  }
}
