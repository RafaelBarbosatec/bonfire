import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/material.dart';

import '../interval_tick.dart';

Paint _paintSensor = Paint()..color = Colors.red.withOpacity(0.5);

mixin Sensor on GameComponent {
  void onContact(GameComponent component);

  int _intervalCheckContact = 0;
  IntervalTick? _tick;
  Vector2Rect? _sensorArea;

  CollisionConfig? _collisionConfig;

  Vector2Rect get sensorArea {
    if (_sensorArea != null) {
      return _sensorArea!.translate(position.left, position.top);
    } else {
      if (this.isObjectCollision()) {
        return (this as ObjectCollision).getRectCollision();
      } else {
        return this.position;
      }
    }
  }

  void setupSensorArea(Vector2Rect s, {int intervalCheck = 250}) {
    _sensorArea = s;
    _intervalCheckContact = intervalCheck;
    _collisionConfig = CollisionConfig(
      collisions: [
        CollisionArea.fromVector2Rect(rect: s),
      ],
    );
  }

  @override
  void update(double dt) {
    if (_collisionConfig == null) {
      _collisionConfig = CollisionConfig(
        collisions: [
          CollisionArea.fromVector2Rect(
            rect: Vector2Rect(Vector2.zero(), position.size),
          ),
        ],
      );
    }
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
    _collisionConfig?.updatePosition(sensorArea);
    for (final i in gameRef.visibleComponents()) {
      if (i.isObjectCollision()) {
        if ((i as ObjectCollision)
                .collisionConfig
                ?.verifyCollision(_collisionConfig) ??
            false) {
          onContact(i);
        }
      } else if (i.position.overlaps(sensorArea)) {
        onContact(i);
      }
    }
  }
}
