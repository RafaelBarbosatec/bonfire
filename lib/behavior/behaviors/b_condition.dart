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
  bool process(double dt, GameComponent comp, BonfireGameInterface game) {
    if (condition(dt, comp, game)) {
      return doBehavior.process(dt, comp, game);
    } else {
      return doElseBehavior?.process(dt, comp, game) ?? true;
    }
  }
}
