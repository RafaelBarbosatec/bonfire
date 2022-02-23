import 'package:bonfire/base/bonfire_game_interface.dart';
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
/// on 23/02/22

abstract class GameComponentEvent {}

abstract class GameComponentController<T extends GameComponent> {
  late final T component;
  late BonfireGameInterface gameRef;

  void update(double dt) {}
}
