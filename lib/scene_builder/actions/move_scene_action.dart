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
class MoveComponentSceneAction<T extends Movement> extends SceneAction {
  final T component;
  final Vector2 newPosition;

  Vector2 _diffPosition = Vector2.zero();

  MoveComponentSceneAction({
    dynamic id,
    required this.component,
    required this.newPosition,
  }) : super(id);

  @override
  bool runAction(double dt, BonfireGameInterface game) {
    var diffPosition = newPosition - component.position;

    var dtSpeed = component.speed * dt;
    if (diffPosition.x.abs() < dtSpeed && diffPosition.y.abs() < dtSpeed) {
      component.stopMove();
      return true;
    }

    var d = _diffPosition - diffPosition;
    if (d.isZero()) {
      component.stopMove();
      return true;
    }
    _diffPosition = diffPosition;
    var radAngle = atan2(diffPosition.y, diffPosition.x);
    component.moveFromAngle(radAngle);
    return false;
  }
}
