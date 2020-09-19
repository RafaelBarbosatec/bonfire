import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/position.dart';

abstract class FollowerObject extends GameComponent {
  final GameComponent target;
  final Position positionFromTarget;
  final double height;
  final double width;

  FollowerObject(
      {this.target, this.positionFromTarget, this.height, this.width});

  @override
  void update(double dt) {
    super.update(dt);
    Position newPosition = positionFromTarget ?? Position.empty();
    this.position = Rect.fromLTWH(
      target.position.left,
      target.position.top,
      width,
      height,
    ).translate(newPosition.x, newPosition.y);
  }

  @override
  int priority() => PriorityLayer.OBJECTS;
}
