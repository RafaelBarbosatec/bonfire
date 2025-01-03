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
export 'behaviors/b_random_movement.dart';
export 'behaviors/b_see_and_move_to_target.dart';
export 'behaviors/b_see_and_positioned.dart';
export 'use_behavior.dart';

abstract class Behavior {
  final dynamic id;

  Behavior({this.id});
  // return true if yet running or false to finish behavior
  bool runAction(double dt, GameComponent comp, BonfireGameInterface game);
}
