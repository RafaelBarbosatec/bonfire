import 'package:bonfire/base/bonfire_game_interface.dart';

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
abstract class SceneAction {
  final dynamic id;

  SceneAction(this.id);
  bool runAction(double dt, BonfireGameInterface game);
}
