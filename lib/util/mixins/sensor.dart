import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:flutter/widgets.dart';

import '../interval_tick.dart';

Color sensorColor = Color(0xFFF44336).withOpacity(0.5);

/// Mixin responsible for adding trigger to detect other objects above
mixin Sensor on GameComponent {
  void onContact(GameComponent component);

  int _intervalCheckContact = 250;
  IntervalTick? _tick;

  CollisionConfig? _collisionConfig;

  Iterable<CollisionArea> get sensorArea {
    if (_collisionConfig != null) {
      return _collisionConfig!.collisions;
    }
    if (this.isObjectCollision()) {
      return (this as ObjectCollision).collisionConfig!.collisions;
    } else {
      return [
        CollisionArea.rectangle(
          size: size,
        )
      ];
    }
  }

  void setupSensorArea({
    List<CollisionArea>? areaSensor,
    int intervalCheck = 250,
  }) {
    _intervalCheckContact = intervalCheck;
    if (areaSensor != null) {
      _collisionConfig = CollisionConfig(
        collisions: areaSensor,
      );
    }
  }

  @override
  void update(double dt) {
    if (_collisionConfig == null) {
      _collisionConfig = CollisionConfig(
        collisions: sensorArea,
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
      sensorArea.forEach((element) {
        element.render(c, sensorColor);
      });
    }
  }

  void _verifyContact() {
    _collisionConfig?.updatePosition(position);
    for (final i in gameRef.visibleComponents()) {
      if (i != this) {
        if (i.isObjectCollision()) {
          if (((i as ObjectCollision)
                  .collisionConfig
                  ?.verifyCollision(_collisionConfig) ??
              false)) {
            onContact(i);
          }
        } else if (i.toRect().overlaps(_collisionConfig?.rect ?? Rect.zero)) {
          onContact(i);
        }
      }
    }
  }
}
