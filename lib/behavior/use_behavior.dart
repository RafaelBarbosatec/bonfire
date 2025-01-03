import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/behavior/behavior.dart';

mixin UseBehavior on GameComponent {
  List<Behavior> get behaviors;
  late BehaviorManager _behaviorManager;

  @override
  void onMount() {
    super.onMount();
    add(
      _behaviorManager = BehaviorManager(
        behaviors: behaviors,
      ),
    );
  }

  void updateBehaviors(List<Behavior> behaviors) {
    _behaviorManager.updateBehaviors(behaviors);
  }

  bool get behaviorIsRunning => _behaviorManager.isRunning;

  void toggleBehavior() {
    if (_behaviorManager.isRunning) {
      pauseBehaviors();
    } else {
      resumeBehaviors();
    }
  }

  void pauseBehaviors() {
    _behaviorManager.pause();
  }

  void resumeBehaviors() {
    _behaviorManager.resume();
  }
}
