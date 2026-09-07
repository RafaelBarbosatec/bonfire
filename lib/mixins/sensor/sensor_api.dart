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
  final GameComponent _comp;

  bool enabled = true;

  final List<SensorContactCallback<T>> _onContactCallbacks = [];
  final List<SensorContactCallback<T>> _onContactExitCallbacks = [];

  IntervalTick _intervalTick = IntervalTick(
    100,
  );

  SensorApi(this._comp);

  void setup({int interval = 100, bool enabled = true}) {
    this.enabled = enabled;
    _intervalTick = IntervalTick(
      interval,
    );
  }

  /// Register callback fired while contact is detected.
  void onContactListener(SensorContactCallback<T> callback) {
    _onContactCallbacks.add(callback);
  }

  /// Register callback fired when contact ends.
  void onContactEndListener(SensorContactCallback<T> callback) {
    _onContactExitCallbacks.add(callback);
  }

  Future<void> ensureCollisionShape() async {
    final containsShape = _comp.children.query<ShapeHitbox>().isNotEmpty;
    if (!containsShape) {
      _comp.add(
        RectangleHitbox(
          size: _comp.size,
          isSolid: true,
          collisionType: CollisionType.passive,
        ),
      );
    }
  }

  void handleCollision(PositionComponent other) {
    if (other is! T || !enabled) {
      return;
    }
    final tick = _intervalTick.update(_comp.lastDt);
    if (tick) {
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
