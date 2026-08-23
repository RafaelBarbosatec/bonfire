import 'package:bonfire/bonfire.dart';

class BSeeAndPositioned extends Behavior {
  final GameComponent target;
  final double radiusVision;
  final double? visionAngle;
  final Behavior? doElseBehavior;
  final double? minDistance;
  final void Function(GameComponent target, double dt) positioned;

  final IntervalTick _intervalTick = IntervalTick(
    500,
  );

  BSeeAndPositioned({
    required this.target,
    required this.positioned,
    this.radiusVision = 32,
    this.visionAngle,
    this.doElseBehavior,
    this.minDistance,
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
            comp.stop();
          }
          return doElseBehavior?.runAction(dt, comp, game) ?? true;
        },
      ),
      doBehavior: (target) {
        return BCustom(
          behavior: (dt, comp, game) {
            if (comp is Movement) {
              final minD = minDistance ?? (radiusVision * 0.7);
              final inDistance = comp.keepDistance(
                target,
                minD,
              );
              if (inDistance) {
                final playerDirection = comp.getDirectionToTarget(
                  target,
                );

                comp.direction = playerDirection;

                if (_intervalTick.update(
                  dt,
                )) {
                  comp.stop();
                }
                positioned.call(target, dt);
              }
            }
            return true;
          },
        );
      },
    ).runAction(dt, comp, game);
  }
}
