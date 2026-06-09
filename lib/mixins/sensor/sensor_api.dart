import 'dart:async';

import 'package:bonfire/bonfire.dart';

typedef SensorContactCallback<T extends GameComponent> = void Function(
  T component,
);

/// API for managing sensor behavior.
///
/// This class encapsulates contact detection interval, enabled state,
/// and collision handling callbacks.
class SensorApi<T extends GameComponent> {
  static const String _sensorIntervalKey = 'SensorContact';

  final GameComponent comp;

  int _intervalCallback = 100;
  bool _enabled = true;

  final List<SensorContactCallback<T>> _onContactCallbacks = [];
  final List<SensorContactCallback<T>> _onContactExitCallbacks = [];

  SensorApi(this.comp);

  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  int get interval => _intervalCallback;
  set interval(int value) => _intervalCallback = value;

  /// Register callback fired while contact is detected.
  void onContactListener(SensorContactCallback<T> callback) {
    _onContactCallbacks.add(callback);
  }

  /// Register callback fired when contact ends.
  void onContactEndListener(SensorContactCallback<T> callback) {
    _onContactExitCallbacks.add(callback);
  }

  Future<void> ensureCollisionShape() async {
    final containsShape = comp.children.query<ShapeHitbox>().isNotEmpty;
    if (!containsShape) {
      comp.add(
        RectangleHitbox(
          size: comp.size,
          isSolid: true,
          collisionType: CollisionType.passive,
        ),
      );
    }
  }

  void handleCollision(PositionComponent other) {
    if (other is! T || !_enabled) {
      return;
    }

    if (comp.checkInterval(
      _sensorIntervalKey,
      _intervalCallback,
      comp.lastDt,
    )) {
      for (final callback in _onContactCallbacks) {
        callback(other);
      }
    }
  }

  void handleCollisionEnd(PositionComponent other) {
    if (other is T) {
      for (final callback in _onContactExitCallbacks) {
        callback(other);
      }
    }
  }

  /// Clean up all listeners.
  void dispose() {
    _onContactCallbacks.clear();
    _onContactExitCallbacks.clear();
  }
}
