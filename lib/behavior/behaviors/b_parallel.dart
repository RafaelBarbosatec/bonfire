import 'package:bonfire/bonfire.dart';

/// Runs all its children **in parallel**, every frame.
///
/// The parallel is finished (returns `true`) only when **all** children are
/// finished. Useful to combine independent actions, e.g. move + attack +
/// play an animation at the same time.
///
/// ```dart
/// BParallel(
///   behaviors: [
///     BMoveToComponent(target: player),
///     BAction(action: (dt, comp, game) => attack.melee(damage: 10, size: Vector2.all(32))),
///   ],
/// )
/// ```
class BParallel extends Behavior {
  final List<Behavior> behaviors;

  BParallel({required this.behaviors, super.id});

  @override
  bool process(double dt, GameComponent comp, BonfireGameInterface game) {
    var allFinished = true;
    for (final behavior in behaviors) {
      if (!behavior.process(dt, comp, game)) {
        allFinished = false;
      }
    }
    return allFinished;
  }
}
