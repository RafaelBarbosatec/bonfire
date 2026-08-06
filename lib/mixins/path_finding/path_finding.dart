import 'package:bonfire/bonfire.dart';

export 'path_finding_api.dart';

/// Mixin responsible for finding paths using A* and moving the component
/// through them.
///
/// The component must have a [Movement] mixin.
///
/// Access all path finding functionality through the [pathFinding] API:
/// ```dart
/// class MyPlayer extends HumanPlayer with WithPathFinding, TapGesture {
///   @override
///   void onTapDownScreen(GestureEvent event) {
///     pathFinding.moveToPosition(event.worldPosition);
///     super.onTapDownScreen(event);
///   }
/// }
/// ```
mixin WithPathFinding on Movement {
  late final PathFindingApi pathFinding = PathFindingApi(this);

  @override
  void update(double dt) {
    pathFinding.update(dt);
    super.update(dt);
  }

  @override
  void renderTree(Canvas canvas) {
    pathFinding.render(canvas);
    super.renderTree(canvas);
  }

  @override
  void onRemove() {
    pathFinding.dispose();
    super.onRemove();
  }
}
