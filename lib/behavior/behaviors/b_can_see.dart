import 'package:bonfire/bonfire.dart';

class BCanSee extends Behavior {
  final GameComponent target;
  final double radiusVision;
  final double? visionAngle;
  final double angle;
  final Behavior Function(GameComponent comp) doBehavior;
  final Behavior? doElseBehavior;

  BCanSee({
    required this.target,
    required this.doBehavior,
    this.radiusVision = 32,
    this.visionAngle,
    this.angle = 3.14159,
    this.doElseBehavior,
  });

  @override
  bool process(double dt, GameComponent comp, BonfireGameInterface game) {
    if (comp is WithVision) {
      var see = false;
      comp.vision.seeComponent(
        target,
        radiusVision: radiusVision,
        visionAngle: visionAngle,
        angle: angle,
        observed: (c) {
          see = true;
        },
      );
      if (see) {
        return doBehavior(target).process(dt, comp, game);
      }
      return doElseBehavior?.process(dt, comp, game) ?? true;
    } else {
      return true;
    }
  }
}
