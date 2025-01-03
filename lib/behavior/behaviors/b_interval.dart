import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/behavior/behavior.dart';
import 'package:bonfire/util/interval_tick.dart';

class BInterval extends Behavior {
  final Behavior doBehavior;
  final int interval;
  late IntervalTick _intervalTick;

  BInterval({
    required this.doBehavior,
    required this.interval,
    super.id,
  }) : assert(interval > 0) {
    _intervalTick = IntervalTick(interval);
  }

  @override
  bool runAction(double dt, GameComponent comp, BonfireGameInterface game) {
    if (_intervalTick.update(dt)) {
      return doBehavior.runAction(dt, comp, game);
    }
    return true;
  }
}
