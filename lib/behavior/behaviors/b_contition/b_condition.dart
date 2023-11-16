import 'package:bonfire/behavior/behavior.dart';
import 'package:bonfire/bonfire.dart';

export 'condition.dart';

class BCondition extends Behavior {
  final Condition condition;
  final Behavior doBehavior;
  final Behavior? doElseBehavior;

  BCondition({
    dynamic id,
    required this.condition,
    required this.doBehavior,
    this.doElseBehavior,
  }) : super(id);

  @override
  bool runAction(double dt, GameComponent comp, BonfireGameInterface game) {
    if (condition.execute(comp, game)) {
      return doBehavior.runAction(dt, comp, game);
    } else {
      return doElseBehavior?.runAction(dt, comp, game) ?? false;
    }
  }
}
