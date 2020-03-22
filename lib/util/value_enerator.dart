import 'package:flutter/widgets.dart';

class ValueGenerator {
  final TickerProvider vsync;
  final Duration duration;
  final double begin;
  final double end;
  VoidCallback _finish;
  ValueChanged<double> _valueChanged;
  AnimationController _controller;
  CurvedAnimation _curvedAnimation;
  Animation<double> _animation;
  bool disposed = false;

  ValueGenerator(
    this.vsync,
    this.duration, {
    this.begin = 0.0,
    this.end = 1.0,
  }) {
    createController();
  }

  void addListenerFinish(VoidCallback finish) {
    _finish = finish;
  }

  void addListenerValue(ValueChanged<double> valueChanged) {
    _valueChanged = valueChanged;
  }

  void addCurve(Curve curve) {
    if (disposed) return;
    _curvedAnimation = CurvedAnimation(curve: curve, parent: _controller);
    _animation =
        Tween<double>(begin: begin, end: end).animate(_curvedAnimation);
  }

  void start() {
    if (disposed) return;
    _controller.forward(from: 0.0);
  }

  void createController() {
    _controller = AnimationController(vsync: vsync, duration: duration);
    _controller.addListener(() {
      if (_valueChanged != null) _valueChanged(_animation.value);
    });
    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          disposed = true;
          if (_finish != null) _finish();
          _controller.dispose();
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          disposed = true;
          if (_finish != null) _finish();
          _controller.dispose();
          break;
      }
    });
    _animation = Tween<double>(
      begin: begin,
      end: end,
    ).animate(_controller);
    disposed = false;
  }
}
