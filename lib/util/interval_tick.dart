import 'dart:ui';

class IntervalTick {
  late int interval; // in Milliseconds
  final VoidCallback? onTick;
  double _currentTime = 0;
  bool _running = true;
  late double _intervalSeconds;
  IntervalTick(this.interval, {this.onTick}) {
    _intervalSeconds = interval / 1000;
  }

  bool update(double dt) {
    if (_running) {
      _currentTime += dt;
      if (_currentTime >= _intervalSeconds) {
        onTick?.call();
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

  void tick() {
    _currentTime = _intervalSeconds;
  }

  bool get running => _running;
}
