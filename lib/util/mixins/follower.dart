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
mixin Follower on PositionComponent {
  PositionComponent? followerTarget;
  Vector2? followerPositionFromTarget;

  void setupFollower(
    PositionComponent followerTarget, {
    Vector2? followerPositionFromTarget,
  }) {
    this.followerTarget = followerTarget;
    this.followerPositionFromTarget = followerPositionFromTarget;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (followerTarget != null) {
      final newPosition = followerPositionFromTarget ?? Vector2.zero();
      this.position = followerTarget!.position +
          Vector2(
            newPosition.x,
            newPosition.y,
          );
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
}
