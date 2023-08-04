import 'dart:ui';

class IntervalTick {
  late int interval; // in Milliseconds
  final VoidCallback? tick;
  double _currentTime = 0;
  bool _running = true;
  late double _intervalSeconds;
  IntervalTick(this.interval, {this.tick}) {
    _intervalSeconds = interval / 1000;
  }

  bool update(double dt) {
    if (_running) {
      _currentTime += dt;
      if (_currentTime >= _intervalSeconds) {
        tick?.call();
        reset();
        return true;
      }
    }

    return false;
  }

  void reset() {
    _currentTime = 0;
  }

  void pause() {
    _running = false;
  }

  void play() {
    _running = true;
  }

  bool get running => _running;
}
