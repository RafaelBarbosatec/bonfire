import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

final Color sensorColor = Color(0xFFF44336).withOpacity(0.5);

/// Mixin responsible for adding trigger to detect other objects above
mixin Sensor on GameComponent {
  void onContact(GameComponent component);

  bool enabledSensor = true;

  int _intervalCheckContact = 250;
  String _intervalCheckContactKey = 'KEY_CHECK_SENSOR_CONTACT';

  CollisionConfig? _collisionConfig;

  Iterable<CollisionArea> get _sensorArea {
    if (_collisionConfig != null) {
      return _collisionConfig!.collisions;
    }

    if (this.isObjectCollision()) {
      return (this as ObjectCollision).collisionConfig!.collisions;
    }

    return [
      CollisionArea.rectangle(size: size),
    ];
  }

  void setupSensorArea({
    List<CollisionArea>? areaSensor,
    int intervalCheck = 250,
  }) {
    _intervalCheckContact = intervalCheck;
    _collisionConfig = CollisionConfig(
      collisions: areaSensor ?? _sensorArea,
    );
  }

  @override
  void update(double dt) {
    if (enabledSensor) {
      if (_collisionConfig == null) {
        _collisionConfig = CollisionConfig(collisions: _sensorArea);
      }
      if (checkInterval(_intervalCheckContactKey, _intervalCheckContact, dt)) {
        _collisionConfig?.updatePosition(position);
        _verifyContact();
      }
    }
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    if (gameRef.showCollisionArea) {
      for (final area in _sensorArea) {
        area.render(c, sensorColor);
      }
    }
  }

  void _verifyContact() {
    for (final vComp in gameRef.visibleComponents()) {
      if (vComp != this) {
        if (vComp.isObjectCollision()) {
          final hasContact = (vComp as ObjectCollision)
              .collisionConfig!
              .verifyCollision(_collisionConfig);
          if (hasContact) {
            onContact(vComp);
          }
        } else if (vComp.toRect().overlaps(_collisionConfig!.rect)) {
          onContact(vComp);
        }
      }
    }
  }
}
