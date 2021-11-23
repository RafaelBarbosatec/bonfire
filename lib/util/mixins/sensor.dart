import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/widgets.dart';

import '../interval_tick.dart';

Paint _paintSensor = Paint()..color = Color(0xFFF44336).withOpacity(0.5);

/// Mixin responsible for adding trigger to detect other objects above
mixin Sensor on GameComponent {
  void onContact(GameComponent component);

  int _intervalCheckContact = 250;
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

  void setupSensorArea({
    Vector2? size,
    Vector2? align,
    int intervalCheck = 250,
  }) {
    _intervalCheckContact = intervalCheck;
    if (size != null || align != null) {
      if (size != null) {
        _sensorArea = Vector2Rect(align ?? Vector2.zero(), size);
      } else if (align != null) {
        _sensorArea = Vector2Rect(align, this.position.size);
      }
      _collisionConfig = CollisionConfig(
        collisions: [
          CollisionArea.fromVector2Rect(rect: _sensorArea!),
        ],
      );
    }
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
    if ((gameRef as BonfireGame).showCollisionArea) {
      c.drawRect(sensorArea.rect, _paintSensor);
    }
  }

  void _verifyContact() {
    _collisionConfig?.updatePosition(sensorArea);
    for (final i in gameRef.visibleComponents()) {
      if (i != this) {
        if (i.isObjectCollision()) {
          if (((i as ObjectCollision)
                  .collisionConfig
                  ?.verifyCollision(_collisionConfig) ??
              false)) {
            onContact(i);
          }
        } else if (i.position.overlaps(sensorArea)) {
          onContact(i);
        }
      }
    }
  }
}
