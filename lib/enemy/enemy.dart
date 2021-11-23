import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/mixins/movement.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

/// It is used to represent your enemies.
class Enemy extends GameComponent with Movement, Attackable {
  Enemy({
    required Vector2 position,
    required double height,
    required double width,
    double life = 10,
    double speed = 100,
  }) {
    this.speed = speed;
    receivesAttackFrom = ReceivesAttackFromEnum.PLAYER;
    initialLife(life);
    this.position = Vector2Rect.fromRect(
      Rect.fromLTWH(
        position.x,
        position.y,
        width,
        height,
      ),
    );
  }
}
