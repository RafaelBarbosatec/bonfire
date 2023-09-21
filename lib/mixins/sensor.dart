import 'dart:async';

import 'package:bonfire/bonfire.dart';

final Color sensorColor = const Color(0xFFF44336).withOpacity(0.5);

/// Mixin responsible for adding trigger to detect other objects above
/// T is a type that Sensor will be find contact.
mixin Sensor<T extends GameComponent> on GameComponent {
  static const _sensorIntervalKey = 'SensorContact';
  int _intervalCallback = 100;
  GameComponent? componentIncontact;
  bool sensorEnabled = true;

  void onContact(T component) {}
  void onContactExit(T component) {}

  void setSensorInterval(int intervalCallback) {
    _intervalCallback = intervalCallback;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (componentIncontact != null && sensorEnabled) {
      if (checkInterval(_sensorIntervalKey, _intervalCallback, dt)) {
        onContact(componentIncontact! as T);
      }
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    bool containsShape = children.query<ShapeHitbox>().isNotEmpty;
    if (!containsShape) {
      add(RectangleHitbox(size: size, isSolid: true));
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is T) {
      componentIncontact = other;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (componentIncontact == other) {
      componentIncontact = null;
      onContactExit(other as T);
      resetInterval(_sensorIntervalKey);
    }
    super.onCollisionEnd(other);
  }

  @override
  int get priority => LayerPriority.MAP + 1;
}
