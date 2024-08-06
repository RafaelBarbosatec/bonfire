import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/scene_builder/scene_action.dart';
import 'package:flutter/material.dart';

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

/// SceneAction that do something until the `completed` callback is called.
class CallbackSceneAction extends SceneAction {
  bool _isDone = false;
  bool _isFirstRun = true;
  final ValueChanged<VoidCallback> completedCallback;

  CallbackSceneAction({required this.completedCallback, dynamic id})
      : super(id);

  @override
  bool runAction(double dt, BonfireGameInterface game) {
    if (_isFirstRun) {
      _isFirstRun = false;
      completedCallback(() => _isDone = true);
    }
    return _isDone;
  }
}
