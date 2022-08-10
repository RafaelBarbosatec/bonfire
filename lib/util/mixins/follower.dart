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
  Vector2 _zero = Vector2.zero();

  void setupFollower(
    GameComponent? followerTarget, {
    Vector2? followerOffset,
  }) {
    this.followerTarget = followerTarget;
    this.followerOffset = followerOffset;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (followerTarget != null) {
      final newPosition = followerOffset ?? _zero;
      this.position = followerTarget!.position + newPosition;
    }
  }

  @override
  void onMount() {
    if (followerTarget == null) {
      followParent();
    }
    super.onMount();
  }

  void followParent() {
    if (parent != null && parent is GameComponent) {
      followerTarget = parent as GameComponent;
    }
  }
}
