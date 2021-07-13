import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/interval_tick.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/mixins/movement.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// It is used to represent your enemies.
class Enemy extends GameComponent with Movement, Attackable {
  /// Map available to store times that can be used to control the frequency of any action.
  Map<String, IntervalTick> timers = Map();

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

  /// Checks whether you entered a certain configured interval
  /// Used in flows involved in the [update]
  bool checkPassedInterval(String name, int intervalInMilli, double dt) {
    if (this.timers[name]?.interval != intervalInMilli) {
      this.timers[name] = IntervalTick(intervalInMilli);
      return true;
    } else {
      return this.timers[name]?.update(dt) ?? false;
    }
  }
}
