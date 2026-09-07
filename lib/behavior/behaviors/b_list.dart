import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/behavior/behavior.dart';

class BList extends Behavior {
  final List<Behavior> behaviors;

  BList({required this.behaviors, super.id});

  int _currentIdex = 0;
  @override
  bool process(double dt, GameComponent comp, BonfireGameInterface game) {
    final current = behaviors[_currentIdex];
    if (current.process(dt, comp, game)) {
      _currentIdex++;
    }
    return _currentIdex >= behaviors.length;
  }
}
