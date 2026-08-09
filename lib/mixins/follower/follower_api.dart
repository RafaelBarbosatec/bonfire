import 'package:bonfire/base/game_component.dart';
import 'package:flame/components.dart';

/// API that handles following a target [GameComponent].
///
/// If [target] is null, the component will follow its parent.
class FollowerApi {
  final GameComponent _comp;

  GameComponent? _target;
  Vector2? _offset;
  Vector2? _lastTargetPosition;
  final Vector2 _zero = Vector2.zero();

  FollowerApi(this._comp);

  /// The target component being followed.
  GameComponent? get target => _target;

  /// The offset applied to the target's position.
  Vector2? get offset => _offset;

  /// Sets up the follower behavior.
  ///
  /// [target] - the component to follow. If null, keeps the current target.
  /// [offset] - the offset to apply. If null, keeps the current offset.
  void setup({
    GameComponent? target,
    Vector2? offset,
  }) {
    _target = target ?? _target;
    _offset = offset ?? _offset;
  }

  /// Removes the current follow target.
  void removeTarget() {
    _target = null;
  }

  /// Updates the component position to match the target.
  void update(double dt) {
    final target = _target;
    if (target != null && _lastTargetPosition != target.absolutePosition) {
      _lastTargetPosition = target.absolutePosition.clone();
      _comp.position = _lastTargetPosition! + (_offset ?? _zero);
    }
  }

  /// Returns the target priority if available, otherwise falls back to the
  /// component's own priority.
  int get priority => _target?.priority ?? _comp.priority;
}
