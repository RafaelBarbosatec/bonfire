import 'package:bonfire/bonfire.dart';

class BCondition extends Behavior {
  final bool Function(double dt, GameComponent comp, BonfireGameInterface game)
      condition;

  final Behavior doBehavior;
  final Behavior? doElseBehavior;

  BCondition({
    required this.condition,
    required this.doBehavior,
    super.id,
    this.doElseBehavior,
  });

  @override
  bool runAction(double dt, GameComponent comp, BonfireGameInterface game) {
    if (condition(dt, comp, game)) {
      return doBehavior.runAction(dt, comp, game);
    } else {
      return doElseBehavior?.runAction(dt, comp, game) ?? true;
    }
  }
}
