import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/cupertino.dart';

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

abstract class StateController<T extends GameComponent> extends ChangeNotifier {
  final List<T> components = [];
  T? get component => components.isNotEmpty ? components.first : null;

  BonfireGameInterface get gameRef {
    if (component == null) {
      throw StateError(
        'Cannot find reference $BonfireGameInterface in the component',
      );
    }
    return component!.gameRef;
  }

  void update(double dt) {}
  void onReady(T component) {
    components.add(component);
  }

  void onRemove(T component) {
    components.remove(component);
  }
}
