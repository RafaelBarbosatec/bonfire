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

abstract class StateController<T extends GameComponent> {
  final List<T> components = [];
  T? get component => components.isNotEmpty ? components.first : null;
  BonfireGameInterface? _gameRef;

  BonfireGameInterface get gameRef {
    if (_gameRef == null) {
      throw StateError(
        'Cannot find reference $BonfireGameInterface in the component',
      );
    }
    return _gameRef!;
  }

  void update(double dt) {}
  void onReady(T component) {
    components.add(component);
    _gameRef = component.gameRef;
  }

  void onRemove(T component) {
    components.remove(component);
    if (components.isEmpty) {
      _gameRef = null;
    }
  }
}
