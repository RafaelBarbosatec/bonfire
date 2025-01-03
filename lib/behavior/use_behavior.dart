import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/behavior/behavior.dart';

mixin UseBehavior on GameComponent {
  List<Behavior> get behaviors;

  @override
  void onMount() {
    super.onMount();
    add(
      BehaviorManager(
        behaviors: behaviors,
      ),
    );
  }
}
