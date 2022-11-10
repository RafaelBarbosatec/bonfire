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
  GameComponent? followerTarget;
  Vector2? followerOffset;
  Vector2? _lastFollowerPosition;
  final Vector2 _zero = Vector2.zero();

  void setupFollower({
    GameComponent? target,
    Vector2? offset,
  }) {
    followerTarget = target;
    followerOffset = offset;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (followerTarget != null &&
        _lastFollowerPosition != followerTarget?.position) {
      _lastFollowerPosition = followerTarget!.position.clone();
      position = _lastFollowerPosition! + (followerOffset ?? _zero);
    }
  }

  @override
  void onMount() {
    super.onMount();
    if (followerTarget == null) {
      followParent();
    }
  }

  void followParent() {
    if (parent != null && parent is GameComponent) {
      followerTarget = parent as GameComponent;
    }
  }

  @override
  int get priority => followerTarget?.priority ?? super.priority;
}
