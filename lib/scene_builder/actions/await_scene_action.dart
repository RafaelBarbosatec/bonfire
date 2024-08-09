import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/scene_builder/scene_action.dart';

class AwaitSceneAction extends SceneAction {
  final Future<void> Function() wait;

  AwaitSceneAction({required this.wait, dynamic id}) : super(id);

  bool _isDone = false;
  bool _isFirstRun = true;

  @override
  bool runAction(double dt, BonfireGameInterface game) {
    if (_isFirstRun) {
      _isFirstRun = false;
      _run();
    }
    return _isDone;
  }

  Future<void> _run() async {
    await wait();
    _isDone = true;
  }
}
