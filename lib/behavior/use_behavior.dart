import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';

/// Adds a behavior system to a [GameComponent], allowing you to program the
/// component AI declaratively — without filling `update()` with `if`s.
///
/// Override [behaviors] with the list of behaviors that should run in sequence:
///
/// ```dart
/// class MyEnemy extends SimpleEnemy with UseBehavior {
///   @override
///   late final List<Behavior> behaviors = [
///     BCondition(
///       condition: (_, comp, game) => comp.vision.seePlayer(observed: (_) {}),
///       doBehavior: BSeeAndMoveToTarget(
///         target: gameRef.player!,
///         onClose: (dt, target) => attack.melee(damage: 10, size: Vector2.all(32)),
///       ),
///       doElseBehavior: BRandomMovement(),
///     ),
///   ];
/// }
/// ```
mixin UseBehavior on GameComponent {
  /// The list of behaviors to run. Prefer a `late final` field (created once)
  /// so internal behavior state (interval ticks, indexes, etc.) is preserved.
  List<Behavior> get behaviors;

  /// When `true`, prints a log every time the current behavior changes.
  /// Useful to debug your AI. Set it before the component is mounted
  /// (e.g. in the constructor).
  bool debugBehaviors = false;

  late BehaviorManager _behaviorManager;
  bool _initialized = false;

  /// The `id` of the behavior currently running (see [BehaviorManager.currentBehaviorId]).
  dynamic get currentBehaviorId => _behaviorManager.currentBehaviorId;

  @override
  void onMount() {
    super.onMount();
    add(
      _behaviorManager = BehaviorManager(
        behaviors: behaviors,
        debug: debugBehaviors,
      ),
    );
    _initialized = true;
  }

  @override
  void onGameResize(Vector2 size) {
    if (kDebugMode && _initialized) {
      _behaviorManager.updateBehaviors(behaviors);
    }
    super.onGameResize(size);
  }

  /// Replaces the current behavior list at runtime.
  void updateBehaviors(List<Behavior> behaviors) {
    _behaviorManager.updateBehaviors(behaviors);
  }

  bool get behaviorIsRunning => _behaviorManager.isRunning;

  void toggleBehavior() {
    if (_behaviorManager.isRunning) {
      pauseBehaviors();
    } else {
      resumeBehaviors();
    }
  }

  void pauseBehaviors() {
    _behaviorManager.pause();
  }

  void resumeBehaviors() {
    _behaviorManager.resume();
  }
}
