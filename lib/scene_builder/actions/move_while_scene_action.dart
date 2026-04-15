import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/mixins/movement.dart';
import 'package:bonfire/scene_builder/scene_action.dart';

class MoveWhileSceneAction extends SceneAction {
  final Movement component;
  bool Function(BonfireGameInterface game) whileThis;
  void Function(Movement) doThis;
  MoveWhileSceneAction({
    required this.component,
    required this.whileThis,
    required this.doThis,
    dynamic id,
  }) : super(id);
  @override
  bool runAction(double dt, BonfireGameInterface game) {
    if (whileThis(game)) {
      doThis(component);
      return false;
    } else {
      component.stopMove();
      return true;
    }
  }
}
