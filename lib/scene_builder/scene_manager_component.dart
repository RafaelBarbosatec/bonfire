import 'package:bonfire/bonfire.dart';
import 'package:bonfire/scene_builder/scene_action.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 04/03/22
class SceneBuilderComponent extends Component with BonfireHasGameRef {
  final List<SceneAction> actions;
  int _indexCurrent = 0;

  SceneBuilderComponent(this.actions);

  @override
  void update(double dt) {
    if (actions[_indexCurrent].runAction(dt, gameRef)) {
      if (_indexCurrent < actions.length - 1) {
        _indexCurrent++;
      } else {
        removeFromParent();
      }
    }
    super.update(dt);
  }
}
