import 'package:bonfire/behavior/behavior.dart';
import 'package:bonfire/bonfire.dart';

class BehaviorManager extends Component with BonfireHasGameRef {
  final List<Behavior> behaviors;
  late GameComponent _comp;
  int _indexCurrent = 0;

  BehaviorManager({required this.behaviors});

  @override
  void update(double dt) {
    final currentAction = behaviors[_indexCurrent];
    if (currentAction.runAction(dt, _comp, gameRef)) {
      if (_indexCurrent < behaviors.length - 1) {
        _indexCurrent++;
      } else {
        _indexCurrent = 0;
      }
    }
    super.update(dt);
  }

  @override
  void onMount() {
    _comp = parent as GameComponent;
    super.onMount();
  }
}
