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

typedef EventChanged<T> = void Function(T value);

class EventMap<T> {
  final Type type;
  final EventChanged<T> onEvent;

  EventMap(this.type, this.onEvent);
}

mixin WithController<T extends GameComponentController> on GameComponent {
  late T _controller;

  final List<EventMap> _onEventList = [];
  @override
  void onMount() {
    _controller = BonfireInjector().get();
    _controller.component = this;
    super.onMount();
  }

  void sendEvent<T extends GameComponentEvent>(T event) {
    _controller.onEvent(event);
  }

  void onEvent<T extends GameComponentEvent>(T event) {
    _onEventList.where((element) => element is EventMap<T>).forEach((element) {
      (element as EventMap<T>).onEvent(event);
    });
  }

  void on<T extends GameComponentEvent>(EventChanged<T> onEvent) {
    _onEventList.add(EventMap<T>(T, onEvent));
  }
}
