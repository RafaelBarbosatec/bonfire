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
      final newPosition = followerOffset ?? Vector2.zero();
      this.position = followerTarget!.position + newPosition;
    }
  }

  @override
  int get priority {
    if (followerTarget != null) {
      return followerTarget!.priority;
    } else {
      return super.priority;
    }
  }

  @override
  void onMount() {
    if (followerTarget == null) {
      followeParent();
    }
    super.onMount();
  }

  void followeParent() {
    if (parent != null && parent is GameComponent) {
      followerTarget = parent as GameComponent;
    }
  }
}
