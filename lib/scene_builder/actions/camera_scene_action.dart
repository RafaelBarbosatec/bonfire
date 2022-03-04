import 'package:bonfire/base/bonfire_game_interface.dart';
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
class CameraSceneAction extends SceneAction {
  final Vector2? position;
  final GameComponent? target;
  final Duration duration;

  bool _running = false;
  bool _done = false;

  CameraSceneAction({
    this.position,
    this.target,
    required this.duration,
  });
  CameraSceneAction.position(Vector2 position,
      {Duration duration = const Duration(seconds: 1)})
      : this.position = position,
        this.target = null,
        this.duration = duration;

  CameraSceneAction.target(GameComponent target,
      {Duration duration = const Duration(seconds: 1)})
      : this.position = null,
        this.target = target,
        this.duration = duration;

  @override
  bool runAction(double dt, BonfireGameInterface game) {
    if (!_running) {
      _running = true;
      if (position != null) {
        game.camera.moveToPositionAnimated(
          position!,
          duration: duration,
          finish: () {
            _done = true;
          },
        );
      } else if (target != null) {
        game.camera.moveToTargetAnimated(
          target!,
          duration: duration,
          finish: () {
            _done = true;
          },
        );
      } else {
        return true;
      }
    }
    if (_done) {
      return true;
    }
    return false;
  }
}
