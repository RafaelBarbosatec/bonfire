import 'dart:math';

import 'package:bonfire/bonfire.dart';

class BSeeAndPositioned extends Behavior {
  final GameComponent target;
  final double radiusVision;
  final double? visionAngle;
  final Behavior? doElseBehavior;
  final double? minDistance;
  final void Function(GameComponent target) positioned;
  String _intervalKey = '';

  BSeeAndPositioned({
    required this.target,
    required this.positioned,
    this.radiusVision = 32,
    this.visionAngle,
    this.doElseBehavior,
    this.minDistance,
    super.id,
  }) {
    _intervalKey = 'seeAndPositioned${Random().nextInt(10000)}';
  }
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
        return BCustom(
          behavior: (dt, comp, game) {
            if (comp is Movement) {
              final minD = minDistance ?? (radiusVision * 0.7);
              final inDistance = comp.keepDistance(
                target,
                minD,
              );
              if (inDistance) {
                final playerDirection = comp.getComponentDirectionFromMe(
                  target,
                );
                comp.lastDirection = playerDirection;
                if (comp.lastDirection.isHorizontal) {
                  comp.lastDirectionHorizontal = comp.lastDirection;
                }

                if (comp.checkInterval(_intervalKey, 500, dt)) {
                  comp.stopMove();
                }
                positioned.call(target);
              }
            }
            return true;
          },
        );
      },
    ).runAction(dt, comp, game);
  }
}
