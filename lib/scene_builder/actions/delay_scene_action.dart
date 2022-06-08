import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/scene_builder/scene_action.dart';
import 'package:bonfire/util/interval_tick.dart';

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
/// on 18/05/22

/// SceneAction that apply a delay in your scene.
class DelaySceneAction extends SceneAction {
  late IntervalTick _tick;
  final Duration delay;

  DelaySceneAction(this.delay) : super(null) {
    _tick = IntervalTick(delay.inMilliseconds);
  }

  @override
  bool runAction(double dt, BonfireGameInterface game) {
    return _tick.update(dt);
  }
}
