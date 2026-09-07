import 'package:bonfire/bonfire.dart';

/// Minimal component that only uses [Movement].
class MovableComponent extends GameComponent with Movement {}

/// Component with movement + collision (required by `WithJumper`).
class CollidableComponent extends GameComponent with Movement, WithCollision {}

/// Component with movement + collision + jump.
class JumpingComponent extends GameComponent
    with Movement, WithCollision, WithJumper {}

/// Component with movement + forces.
class ForcedComponent extends GameComponent with Movement, WithForces {}

/// Minimal fake game to satisfy `BonfireHasGameRef`.
///
/// Only the members used by the tested APIs are implemented; anything else
/// falls back to [noSuchMethod] (which throws, so tests must not touch it).
class FakeBonfireGame implements BonfireGameInterface {
  FakeBonfireGame({GlobalForcesSettings? globalForces})
      : globalForces = globalForces ?? GlobalForcesSettings();

  @override
  final GlobalForcesSettings globalForces;

  @override
  bool isVisibleInCamera(PositionComponent c) => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
