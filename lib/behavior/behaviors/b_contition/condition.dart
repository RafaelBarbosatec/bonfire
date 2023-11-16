import 'package:bonfire/bonfire.dart';

export 'conditions/c_can_see.dart';
export 'conditions/c_can_see_type.dart';
export 'conditions/c_custom.dart';

abstract class Condition {
  bool execute(GameComponent comp, BonfireGameInterface game);
}
