import 'dart:math';

import 'package:bonfire/bonfire.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 04/03/22

/// SceneAction that move the componente in the game.
class MoveToPositionSceneAction<T extends Movement> extends SceneAction {
  final T component;
  final Vector2 newPosition;

  Vector2 _diffPosition = Vector2.zero();

  MoveToPositionSceneAction({
    required this.component,
    required this.newPosition,
    dynamic id,
  }) : super(id);

  @override
  bool runAction(double dt, BonfireGameInterface game) {
    final diffPosition = newPosition - component.position;

    final dtSpeed = component.speed * dt;
    if (diffPosition.x.abs() < dtSpeed && diffPosition.y.abs() < dtSpeed) {
      component.stop();
      return true;
    }

    final d = _diffPosition - diffPosition;
    if (d.isZero()) {
      component.stop();
      return true;
    }
    _diffPosition = diffPosition;
    final radAngle = atan2(diffPosition.y, diffPosition.x);
    component.moveByAngle(radAngle);
    return false;
  }
}
