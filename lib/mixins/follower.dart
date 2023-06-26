import 'package:bonfire/base/game_component.dart';
import 'package:flame/components.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 04/02/22
/// Mixin that do the component follow the targe
/// If target is null will try follow your parent
mixin Follower on GameComponent {
  GameComponent? _followerTarget;
  Vector2? followerOffset;
  Vector2? _lastFollowerPosition;
  final Vector2 _zero = Vector2.zero();

  void setupFollower({
    GameComponent? target,
    Vector2? offset,
  }) {
    _followerTarget = target ?? _followerTarget;
    followerOffset = offset ?? followerOffset;
  }

  void removeFollowerTarget() {
    _followerTarget = null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_followerTarget != null &&
        _lastFollowerPosition != _followerTarget?.absolutePosition) {
      _lastFollowerPosition = _followerTarget!.absolutePosition.clone();
      position = _lastFollowerPosition! + (followerOffset ?? _zero);
    }
  }

  @override
  int get priority => _followerTarget?.priority ?? super.priority;
}
