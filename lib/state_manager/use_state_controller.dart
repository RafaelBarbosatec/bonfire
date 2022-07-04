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
    if (!isRemoving) {
      _controller?.update(dt, this);
    }
    super.update(dt);
  }

  @override
  void onRemove() {
    _removeViewFromController();
    super.onRemove();
  }

  @override
  void onGameDetach() {
    _removeViewFromController();
    super.onGameDetach();
  }

  void _removeViewFromController() {
    _controller?.onRemove(this);
    if (_controller?.components.isEmpty == true) {
      _controller = null;
    }
  }
}
