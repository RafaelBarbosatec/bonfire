import 'package:bonfire/bonfire.dart';

export 'pushable_api.dart';

/// Mixin that gives the component a pushable behavior.
///
/// The component must have a [Movement] mixin.
///
/// Access all pushable functionality through the [pushable] API:
/// ```dart
/// class MyBox extends GameObject with Movement, WithCollision, WithPushable {
///   @override
///   void onMount() {
///     super.onMount();
///     pushable.setup(pushableFrom: PushableFromEnum.ALL);
///     pushable.onPushListener((component) => component is Enemy);
///   }
/// }
/// ```
mixin WithPushable on Movement {
  late final PushableApi pushable = PushableApi(this);

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    pushable.handleCollision(intersectionPoints, other);
  }
}
