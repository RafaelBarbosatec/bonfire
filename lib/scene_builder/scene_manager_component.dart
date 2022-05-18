import 'package:bonfire/bonfire.dart';

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

class SceneBuilderStatus {
  final bool isRunning;
  final SceneAction? currentAction;

  SceneBuilderStatus({this.isRunning = false, this.currentAction});

  SceneBuilderStatus copyWith({
    bool? isRunning,
    SceneAction? currentAction,
  }) {
    return SceneBuilderStatus(
      isRunning: isRunning ?? this.isRunning,
      currentAction:
          currentAction != null && currentAction != this.currentAction
              ? currentAction
              : this.currentAction,
    );
  }
}

class SceneBuilderComponent extends Component with BonfireHasGameRef {
  final List<SceneAction> actions;
  int _indexCurrent = 0;

  SceneBuilderComponent(this.actions);

  @override
  void update(double dt) {
    final currentAction = actions[_indexCurrent];
    _modifyStatus(currentAction: currentAction);
    if (currentAction.runAction(dt, gameRef)) {
      if (_indexCurrent < actions.length - 1) {
        _indexCurrent++;
      } else {
        removeFromParent();
      }
    }
    super.update(dt);
  }

  @override
  void onMount() {
    _modifyStatus(isRunning: true);
    super.onMount();
  }

  void _modifyStatus({
    bool? isRunning,
    SceneAction? currentAction,
  }) {
    gameRef.sceneBuilderStatus = gameRef.sceneBuilderStatus.copyWith(
      isRunning: isRunning,
      currentAction: currentAction,
    );
  }

  @override
  void onRemove() {
    _modifyStatus(isRunning: false);
    super.onRemove();
  }
}
