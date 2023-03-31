import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

final Color sensorColor = const Color(0xFFF44336).withOpacity(0.5);

/// Mixin responsible for adding trigger to detect other objects above
/// T is a type that Sensor will be find contact.
mixin Sensor<T extends GameComponent> on GameComponent {
  int _intervalCallback = 100;
  GameComponent? componentIncontact;

  void onContact(GameComponent component) {}
  void onContactEnd(GameComponent component) {}

  List<ShapeHitbox>? areaSensorToAdd;

  void setupSensorArea({
    List<ShapeHitbox>? areaSensor,
    int intervalCallback = 1000,
  }) {
    _intervalCallback = intervalCallback;
    if (areaSensor != null) {
      if (isLoaded) {
        _replaceShapeHitbox(areaSensor);
      } else {
        areaSensorToAdd = areaSensor;
      }
    }
  }

  @override
  void update(double dt) {
    if (areaSensorToAdd != null) {
      _replaceShapeHitbox(areaSensorToAdd!);
      areaSensorToAdd = null;
    }
    if (checkInterval('Sensor.$runtimeType', _intervalCallback, dt)) {
      if (componentIncontact != null) {
        onContact(componentIncontact!);
      }
    }
    super.update(dt);
  }

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    super.onComponentTypeCheck(other);
    return false;
  }

  @override
  Future<void> onLoad() async {
    addAll([RectangleHitbox(size: size)]);
    return super.onLoad();
  }

  void _replaceShapeHitbox(List<ShapeHitbox> areaList) {
    removeAll(children.whereType<ShapeHitbox>());
    areaList.let(addAll);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GameComponent) {
      componentIncontact = other;
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (componentIncontact == other) {
      componentIncontact = null;
      onContactEnd(other as GameComponent);
    }
    super.onCollisionEnd(other);
  }
}
