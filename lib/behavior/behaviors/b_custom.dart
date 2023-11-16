import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/behavior/behavior.dart';

class BCustom extends Behavior {
  final bool Function(double dt, GameComponent comp, BonfireGameInterface game)
      behavior;

  BCustom({dynamic id, required this.behavior}) : super(id);
  @override
  bool runAction(double dt, GameComponent comp, BonfireGameInterface game) {
    return behavior(dt, comp, game);
  }
}
