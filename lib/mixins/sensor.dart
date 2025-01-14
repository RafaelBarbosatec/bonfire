import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/extensions/color_extensions.dart';

/// Mixin responsible for adding trigger to detect other objects above
/// T is a type that Sensor will be find contact.
mixin Sensor<T extends GameComponent> on GameComponent {
  static Color color = const Color(0xFFF44336).setOpacity(0.5);
  static const _sensorIntervalKey = 'SensorContact';
  int _intervalCallback = 100;
  bool sensorEnabled = true;

  void onContact(T component) {}
  void onContactExit(T component) {}

  set sensorInterval(int intervalCallback) {
    _intervalCallback = intervalCallback;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final containsShape = children.query<ShapeHitbox>().isNotEmpty;
    if (!containsShape) {
      add(
        RectangleHitbox(
          size: size,
          isSolid: true,
          collisionType: CollisionType.passive,
        ),
      );
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is T) {
      if (sensorEnabled) {
        if (checkInterval(
          _sensorIntervalKey,
          _intervalCallback,
          lastDt,
        )) {
          onContact(other);
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is T) {
      onContactExit(other);
    }
    super.onCollisionEnd(other);
  }

  @override
  int get priority => LayerPriority.MAP + 1;
}
