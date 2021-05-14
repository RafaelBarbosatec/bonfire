import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

class ValueGeneratorComponent extends Component {
  bool _isFinished = false;
  final int _maxInMicroSeconds = 1000000;

  final Duration duration;
  final double begin;
  final double end;
  final Curve curve;
  final VoidCallback? onFinish;
  final ValueChanged<double>? onChange;

  double _currentValue = 0;
  double _displacement = 0;
  bool _isRunning = false;

  ValueGeneratorComponent(
    this.duration, {
    this.begin = 0,
    this.end = 1,
    this.curve = Curves.decelerate,
    this.onFinish,
    this.onChange,
  }) {
    _displacement = end - begin;
  }

  @override
  void render(Canvas c) {}

  @override
  void update(double dt) {
    if (!_isRunning) return;
    _currentValue += dt * _maxInMicroSeconds;
    if (_currentValue >= duration.inMicroseconds) {
      finish();
    } else {
      double value = _currentValue / duration.inMicroseconds;
      value = curve.transform(value);
      double realValue = begin + (_displacement * value);
      onChange?.call(realValue);
    }
  }

  void finish() {
    _isFinished = true;
    onChange?.call(end);
    onFinish?.call();
    remove();
  }

  void start() {
    _isRunning = true;
  }

  void pause() {
    _isRunning = false;
  }

  void reset() {
    _isRunning = false;
    _currentValue = 0;
  }

  bool get isFinished => _isFinished;
}
