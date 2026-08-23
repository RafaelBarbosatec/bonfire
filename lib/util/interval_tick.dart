import 'dart:ui';

class IntervalTick {
  final VoidCallback? onTick;
  double _currentTime = 0;
  bool _running = true;
  late double _intervalSeconds;
  bool tickFirstUpdate;
  bool _isFistTick = true;
  IntervalTick(int interval, {this.onTick, this.tickFirstUpdate = false}) {
    _intervalSeconds = interval / 1000;
  }

  void updateInterval(int interval) {
    _intervalSeconds = interval / 1000;
  }

  bool update(double dt) {
    if (_running) {
      if (_isFistTick && tickFirstUpdate) {
        _isFistTick = false;
        onTick?.call();
        return true;
      }

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
    _isFistTick = true;
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
