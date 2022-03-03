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

abstract class GameStateController<T extends GameComponent> {
  final List<T> components = [];
  T get component => components.first;
  late BonfireGameInterface gameRef;

  void update(double dt) {}
  void onReady(T component) {
    components.add(component);
    gameRef = component.gameRef;
  }

  void onRemove(T component) {
    components.remove(component);
  }
}
