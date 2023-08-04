import 'dart:async';

import 'package:bonfire/bonfire.dart';

final Color sensorColor = const Color(0xFFF44336).withOpacity(0.5);

/// Mixin responsible for adding trigger to detect other objects above
/// T is a type that Sensor will be find contact.
mixin Sensor<T extends GameComponent> on GameComponent {
  static const _sensorIntervalKey = 'SensorContact';
  int _intervalCallback = 100;
  GameComponent? componentIncontact;

  void onContact(GameComponent component) {}
  void onContactExit(GameComponent component) {}

  void setSensorInterval(int intervalCallback) {
    _intervalCallback = intervalCallback;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (componentIncontact != null) {
      if (checkInterval(_sensorIntervalKey, _intervalCallback, dt)) {
        onContact(componentIncontact!);
      }
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    bool containsShape = children.query<ShapeHitbox>().isNotEmpty;
    if (!containsShape) {
      add(RectangleHitbox(size: size));
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GameComponent) {
      componentIncontact = other;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (componentIncontact == other) {
      componentIncontact = null;
      onContactExit(other as GameComponent);
      resetInterval(_sensorIntervalKey);
    }
    super.onCollisionEnd(other);
  }
}
