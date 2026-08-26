import 'package:bonfire/bonfire.dart';

/// Runs its children in priority order and picks the **first one that is
/// active** (returns `false` from [Behavior.process]).
///
/// Unlike [BList] (sequence), a selector doesn't wait for a child to finish
/// before trying the next one: every frame it starts from the beginning and
/// runs the first child that needs to keep running.
///
/// Useful to express priorities, e.g. "if I see the player, chase them;
/// otherwise patrol":
///
/// ```dart
/// BSelector(
///   behaviors: [
///     BSeeAndMoveToTarget(target: player, onClose: (_, __) {}),
///     BRandomMovement(),
///   ],
/// )
/// ```
class BSelector extends Behavior {
  final List<Behavior> behaviors;

  BSelector({required this.behaviors, super.id});

  @override
  bool process(double dt, GameComponent comp, BonfireGameInterface game) {
    for (final behavior in behaviors) {
      if (!behavior.process(dt, comp, game)) {
        return false; // this child is active, keep running it
      }
    }
    return true; // no child is active, selector is finished
  }
}
