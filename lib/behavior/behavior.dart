import 'package:bonfire/bonfire.dart';

export 'behavior_manager.dart';
export 'behaviors/b_action.dart';
export 'behaviors/b_can_see.dart';
export 'behaviors/b_can_see_type.dart';
export 'behaviors/b_condition.dart';
export 'behaviors/b_custom.dart';
export 'behaviors/b_interval.dart';
export 'behaviors/b_list.dart';
export 'behaviors/b_move_to_component.dart';
export 'behaviors/b_once.dart';
export 'behaviors/b_parallel.dart';
export 'behaviors/b_random_movement.dart';
export 'behaviors/b_see_and_move_to_target.dart';
export 'behaviors/b_see_and_positioned.dart';
export 'behaviors/b_selector.dart';
export 'use_behavior.dart';

/// Base class of a behavior.
///
/// A behavior is processed every frame by the [BehaviorManager] (added by the
/// [UseBehavior] mixin).
///
/// ### Contract of the return value
///
/// [process] returns `true` when the behavior is **finished** (or does not
/// need to keep blocking the sequence), which makes the manager advance to the
/// next behavior. Return `false` to **keep running** this behavior, holding the
/// sequence until it finishes.
///
/// ```dart
/// class MyBehavior extends Behavior {
///   @override
///   bool process(double dt, GameComponent comp, BonfireGameInterface game) {
///     // do something...
///     return true; // finished, advance to the next behavior
///   }
/// }
/// ```
abstract class Behavior {
  final dynamic id;

  Behavior({this.id});

  /// Processes this behavior for the current frame.
  ///
  /// Returns `true` when the behavior is finished and the manager should
  /// advance to the next behavior, or `false` to keep running it on the next
  /// frame.
  bool process(double dt, GameComponent comp, BonfireGameInterface game);
}
