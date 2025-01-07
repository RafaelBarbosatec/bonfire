import 'package:bonfire/bonfire.dart';

class BehaviorManager extends Component with BonfireHasGameRef {
  List<Behavior> _behaviors;
  late GameComponent _comp;
  int _indexCurrent = 0;
  bool _isRunning = true;

  bool get isRunning => _isRunning;

  BehaviorManager({required List<Behavior> behaviors}) : _behaviors = behaviors;

  void updateBehaviors(List<Behavior> behaviors) {
    if (_behaviors.length != behaviors.length) {
      _indexCurrent = 0;
    }
    _behaviors = behaviors;
  }

  @override
  void update(double dt) {
    if (_isRunning && _behaviors.isNotEmpty) {
      final currentAction = _behaviors[_indexCurrent];
      if (currentAction.runAction(dt, _comp, gameRef)) {
        if (_indexCurrent < _behaviors.length - 1) {
          _indexCurrent++;
        } else {
          _indexCurrent = 0;
        }
      }
    }

    super.update(dt);
  }

  void pause() {
    _isRunning = false;
  }

  void resume() {
    _isRunning = true;
  }

  @override
  void onMount() {
    _comp = parent! as GameComponent;
    super.onMount();
  }
}
