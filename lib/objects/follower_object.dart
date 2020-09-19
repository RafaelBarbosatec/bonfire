import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/position.dart';

abstract class FollowerObject extends GameComponent {
  final GameComponent target;
  final Rect positionFromTarget;

  FollowerObject({
    this.target,
    this.positionFromTarget,
  });

  @override
  void update(double dt) {
    super.update(dt);
    Rect newPosition = positionFromTarget ?? Position.empty();
    this.position = Rect.fromLTWH(
      target.position.left,
      target.position.top,
      newPosition.width,
      newPosition.height,
    ).translate(newPosition.left, newPosition.top);
  }

  @override
  int priority() => PriorityLayer.OBJECTS;
}
