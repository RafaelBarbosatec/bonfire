import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/material.dart';

import '../interval_tick.dart';

Paint _paintSensor = Paint()..color = Colors.red.withOpacity(0.5);

mixin Sensor on GameComponent {
  void onContact(GameComponent collision);

  int intervalCheckContact = 250;
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

  set sensorArea(Vector2Rect s) => _sensorArea = s;

  @override
  void update(double dt) {
    if (_tick == null) {
      _tick = IntervalTick(intervalCheckContact, tick: _verifyContact);
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
      Vector2Rect rect = i is ObjectCollision ? i.rectCollision : i.position;
      if (rect.overlaps(sensorArea)) {
        onContact(i);
      }
    }
  }
}
