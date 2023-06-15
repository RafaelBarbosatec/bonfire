import 'dart:async';

import 'package:bonfire/bonfire.dart';

final Color sensorColor = const Color(0xFFF44336).withOpacity(0.5);

/// Mixin responsible for adding trigger to detect other objects above
/// T is a type that Sensor will be find contact.
mixin Sensor<T extends GameComponent> on GameComponent {
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
    if (checkInterval('SensorContact', _intervalCallback, dt)) {
      if (componentIncontact != null) {
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
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is GameComponent) {
      componentIncontact = other;
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (componentIncontact == other) {
      componentIncontact = null;
      onContactExit(other as GameComponent);
    }
    super.onCollisionEnd(other);
  }
}
