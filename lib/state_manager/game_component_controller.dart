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
  final List<EventMap> _onEventList = [];
  T? component;

  void onEvent<T extends GameComponentEvent>(T event) {
    _onEventList.where((element) => element is EventMap<T>).forEach((element) {
      (element as EventMap<T>).onEvent(event);
    });
  }

  void on<T extends GameComponentEvent>(EventChanged<T> onEvent) {
    _onEventList.add(EventMap<T>(T, onEvent));
  }

  void sendEvent<T extends GameComponentEvent>(T event) {
    if (component is WithController) {
      (component as WithController).onEvent(event);
    }
  }
}
