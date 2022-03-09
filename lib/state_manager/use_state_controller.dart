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

mixin UseStateController<T extends StateController> on GameComponent {
  T? _controller;

  bool _doUpdate = false;

  T get controller {
    if (_controller == null) {
      throw StateError(
        'Cannot find reference $T in the component',
      );
    }
    return _controller!;
  }

  bool get hasController => _controller != null;

  @override
  void onMount() {
    _controller = BonfireInjector().get<T>();
    _controller?.onReady(this);
    super.onMount();
  }

  @override
  void update(double dt) {
    if (!shouldRemove && !_doUpdate) {
      _doUpdate = true;
      _controller?.update(dt);
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
    _controller?.onRemove(this);
    if (_controller?.components.isEmpty == true) {
      _controller = null;
    }
    super.onRemove();
  }
}
