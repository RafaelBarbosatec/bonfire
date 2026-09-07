import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/behavior/behavior.dart';

/// Runs [action] **only once** for the lifetime of this instance and then is
/// considered finished (returns `true` from then on).
///
/// Useful for one-shot steps inside a sequence ([BList]) or when combined with
/// [BInterval] to run periodically:
///
/// ```dart
/// BList(
///   behaviors: [
///     BOnce(action: (dt, comp, game) => comp.animation?.playOnce(attackAnim)),
///     BMoveToComponent(target: player),
///   ],
/// )
/// ```
///
/// > Note: since the "once" state lives in the instance, keep your behavior
/// > list in a `late final` field so it isn't recreated every frame.
class BOnce extends Behavior {
  final void Function(double dt, GameComponent comp, BonfireGameInterface game)
      action;

  bool _hasRun = false;

  BOnce({required this.action, super.id});

  @override
  bool process(double dt, GameComponent comp, BonfireGameInterface game) {
    if (!_hasRun) {
      _hasRun = true;
      action(dt, comp, game);
    }
    return true;
  }
}
