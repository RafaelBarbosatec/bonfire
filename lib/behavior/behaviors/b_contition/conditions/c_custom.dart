import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/behavior/behavior.dart';

class CCustom extends Condition {
  final bool Function(GameComponent comp, BonfireGameInterface game) condition;

  CCustom({required this.condition});
  @override
  bool execute(GameComponent comp, BonfireGameInterface game) {
    return condition(comp, game);
  }
}
