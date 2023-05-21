import 'dart:math';

import 'package:bonfire/base/bonfire_game_interface.dart';
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
  final double? speed;

  MoveComponentSceneAction({
    dynamic id,
    required this.component,
    required this.newPosition,
    this.speed,
  }) : super(id);

  @override
  bool runAction(double dt, BonfireGameInterface game) {
    Vector2 diffPosition = newPosition - component.position;
    if (diffPosition.x.abs() < component.speed &&
        diffPosition.y.abs() < component.speed) {
      return true;
    }

    var radAngle = atan2(diffPosition.y, diffPosition.x);
    component.moveFromAngle(radAngle);
    return false;
  }
}
