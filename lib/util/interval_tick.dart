import 'dart:ui';

class IntervalTick {
  late int interval; // in Milliseconds
  final VoidCallback? tick;
  double _currentTime = 0;
  late double _intervalSeconds;
  IntervalTick(this.interval, {this.tick}) {
    _intervalSeconds = interval / 1000;
  }

  bool update(double dt) {
    _currentTime += dt;
    if (_currentTime >= _intervalSeconds) {
      tick?.call();
      _currentTime = 0;
      return true;
    }
    return false;
  }
}
