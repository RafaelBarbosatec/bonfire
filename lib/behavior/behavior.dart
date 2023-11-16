import 'package:bonfire/bonfire.dart';

export 'behavior_manager.dart';
export 'behaviors/b_contition/b_condition.dart';
export 'behaviors/b_custom.dart';
export 'behaviors/b_move_to_component.dart';

abstract class Behavior {
  final dynamic id;

  Behavior(this.id);
  // return true if yet running or false to finish behavior
  bool runAction(double dt, GameComponent comp, BonfireGameInterface game);
}
