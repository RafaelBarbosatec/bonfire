import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/material.dart';

import '../interval_tick.dart';

Paint _paintSensor = Paint()..color = Colors.red.withOpacity(0.5);

mixin Sensor on GameComponent {
  void onContact(GameComponent collision);

  int _intervalCheckContact = 0;
  IntervalTick? _tick;
  Vector2Rect? _sensorArea;

  Vector2Rect get sensorArea {
    if (_sensorArea != null) {
      return _sensorArea!.translate(position.left, position.top);
    } else {
      if (this is ObjectCollision) {
        return (this as ObjectCollision).getRectCollision();
      } else {
        return this.position;
      }
    }
  }

  void setupSensorArea(Vector2Rect s, {int intervalCheck = 250}) {
    _sensorArea = s;
    _intervalCheckContact = intervalCheck;
  }

  @override
  void update(double dt) {
    if (_tick == null || _tick?.interval != _intervalCheckContact) {
      _tick = IntervalTick(_intervalCheckContact, tick: _verifyContact);
    } else {
      _tick?.update(dt);
    }
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    if (gameRef.showCollisionArea) {
      c.drawRect(sensorArea.rect, _paintSensor);
    }
  }

  void _verifyContact() {
    for (final i in gameRef.visibleComponents()) {
      if (i is ObjectCollision) {
        CollisionConfig config = CollisionConfig(
          collisions: [CollisionArea.fromVector2Rect(rect: sensorArea)],
        )..updatePosition(sensorArea);
        if (i.collisionConfig?.verifyCollision(config) ?? false) {
          onContact(i);
        }
      } else if (i.position.overlaps(sensorArea)) {
        onContact(i);
      }
    }
  }
}
