import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/behavior/behavior.dart';

class BAction extends Behavior {
  final void Function(double dt, GameComponent comp, BonfireGameInterface game)
      action;

  BAction({required this.action, super.id});

  @override
  bool runAction(double dt, GameComponent comp, BonfireGameInterface game) {
    action(dt, comp, game);
    return false;
  }
}
