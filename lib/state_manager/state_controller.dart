import 'dart:ui';

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

mixin StateController<T extends GameStateController> on GameComponent {
  late final T controller;

  bool _doUpdate = false;

  @override
  void onMount() {
    controller = BonfireInjector().get();
    controller.onReady(this);
    super.onMount();
  }

  @override
  void update(double dt) {
    if (!shouldRemove && !_doUpdate) {
      _doUpdate = true;
      controller.update(dt);
    }
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    _doUpdate = false;
    super.render(c);
  }

  @override
  void onRemove() {
    controller.onRemove(this);
    super.onRemove();
  }

  T get<T extends GameStateController>() {
    return BonfireInjector().get();
  }
}
