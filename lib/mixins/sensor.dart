import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

final Color sensorColor = const Color(0xFFF44336).withOpacity(0.5);

/// Mixin responsible for adding trigger to detect other objects above
/// T is a type that Sensor will be find contact.
mixin Sensor<T extends GameComponent> on GameComponent {
  void onContact(GameComponent component);
  void onContactExit(GameComponent component) {}

  bool enabledSensor = true;
  List<GameComponent> _componentsInContact = [];

  int _intervalCheckContact = 250;
  bool _checkOnlyVisible = true;
  final String _intervalCheckContactKey = 'KEY_CHECK_SENSOR_CONTACT';

  CollisionConfig? _collisionConfig;

  Iterable<CollisionArea> get _sensorArea {
    if (_collisionConfig != null) {
      return _collisionConfig!.collisions;
    }

    if (isObjectCollision()) {
      return (this as ObjectCollision).collisionConfig!.collisions;
    }

    return [
      CollisionArea.rectangle(size: size),
    ];
  }

  void setupSensorArea({
    List<CollisionArea>? areaSensor,
    int intervalCheck = 250,
    bool checkOnlyVisible = true,
  }) {
    _checkOnlyVisible = checkOnlyVisible;
    _intervalCheckContact = intervalCheck;
    _collisionConfig = CollisionConfig(
      collisions: areaSensor ?? _sensorArea,
    );
  }

  @override
  void update(double dt) {
    if (enabledSensor && (_checkOnlyVisible ? isVisible : true)) {
      if (checkInterval(_intervalCheckContactKey, _intervalCheckContact, dt)) {
        _collisionConfig ??= CollisionConfig(collisions: _sensorArea);
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
    List<GameComponent> compsInContact = [];
    Iterable<GameComponent> compsToCheck = _checkOnlyVisible
        ? gameRef.visibleComponentsByType<T>()
        : gameRef.componentsByType<T>();

    for (final vComp in compsToCheck) {
      if (vComp != this && !vComp.isHud) {
        if (vComp.isObjectCollision()) {
          final hasContact = (vComp as ObjectCollision)
              .collisionConfig!
              .verifyCollision(_collisionConfig);
          if (hasContact) {
            compsInContact.add(vComp);
            onContact(vComp);
          }
        } else if (vComp.toRect().overlaps(_collisionConfig!.rect)) {
          compsInContact.add(vComp);
          onContact(vComp);
        }
      }
    }

    for (final c in _componentsInContact) {
      if (!compsInContact.contains(c)) {
        onContactExit(c);
      }
    }
    _componentsInContact = compsInContact;
  }
}
