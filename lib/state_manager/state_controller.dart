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

mixin StateController<T extends GameComponentController> on GameComponent {
  late final T controller;

  @override
  void onMount() {
    controller = BonfireInjector().get();
    controller.components.add(this);
    controller.gameRef = gameRef;
    super.onMount();
  }

  @override
  void update(double dt) {
    if (!shouldRemove) {
      controller.update(dt);
    }
    super.update(dt);
  }

  @override
  void onRemove() {
    controller.components.remove(this);
    super.onRemove();
  }
}
