import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

/// Component used to generate numbers using the gameLoop.
class ValueGeneratorComponent extends Component {
  bool _isFinished = false;

  final _maxInMilliSeconds = 1000;
  final Duration duration;
  final double begin;
  final double end;
  final Curve curve;
  final Curve? reverseCurve;
  final VoidCallback? onFinish;
  final ValueChanged<double>? onChange;
  final bool autoStart;
  final bool infinite;

  double _currentValue = 0;
  double _displacement = 0;
  bool _isRunning = false;
  bool _reversing = false;

  ValueGeneratorComponent(
    this.duration, {
    this.begin = 0,
    this.end = 1,
    this.curve = Curves.decelerate,
    this.reverseCurve,
    this.onFinish,
    this.onChange,
    this.autoStart = true,
    this.infinite = false,
  }) {
    _isRunning = autoStart;
    _displacement = end - begin;
  }

  @override
  void updateTree(double dt) {
    if (!_isRunning) {
      return;
    }

    if (_reversing) {
      _currentValue -= dt * _maxInMilliSeconds;
    } else {
      _currentValue += dt * _maxInMilliSeconds;
    }

    if (_currentValue >= duration.inMilliseconds) {
      if (infinite) {
        _reversing = true;
      } else {
        finish();
      }
    } else if (_currentValue <= 0 && _reversing) {
      _currentValue = 0;
      _reversing = false;
    } else {
      double realValue;
      if (_reversing) {
        final value = (reverseCurve ?? curve)
            .transform(1 - (_currentValue / duration.inMilliseconds));
        realValue = begin + (_displacement * (1 - value));
      } else {
        final value = curve.transform(_currentValue / duration.inMilliseconds);
        realValue = begin + (_displacement * value);
      }

      onChange?.call(realValue);
    }
  }

  void finish() {
    _isFinished = true;
    onChange?.call(end);
    onFinish?.call();
    removeFromParent();
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
