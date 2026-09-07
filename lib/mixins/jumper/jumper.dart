import 'package:bonfire/bonfire.dart';

export 'jumper_api.dart';

/// Mixin that adds jump behavior for platform games
///
/// This mixin enables jump mechanics including:
/// - Single or multi-jump support
/// - Automatic jump state detection (up, down, idle)
/// - Jump state callbacks via listeners
///
/// Access all jump functionality through the [jumper] API:
/// ```dart
/// mixin GameCharacter on Movement, WithCollision, Jumper {
///   @override
///   void onMount() {
///     super.onMount();
///     jumper.setMaxJump(2);
///     jumper.onJumpStateChangedListener(_onJumpState);
///   }
///
///   void _onJumpState(JumpingStateEnum state) {
///     // Handle jump animation
///   }
/// }
/// ```
mixin WithJumper on Movement, WithCollision {
  late final JumperApi jumper = JumperApi(this);

  @override
  void onMount() {
    super.onMount();
    collision.onMovementBlockedListener(jumper.handleMovementBlocked);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    jumper.handleCollisionStart(intersectionPoints, other);
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    jumper.handleCollisionEnd(other);
    super.onCollisionEnd(other);
  }

  @override
  void update(double dt) {
    jumper.update(dt);
    super.update(dt);
  }

  @override
  void stop() {
    if (!jumper.isJumping) {
      super.stop();
    }
  }

  @override
  void onRemove() {
    jumper.dispose();
    super.onRemove();
  }
}
