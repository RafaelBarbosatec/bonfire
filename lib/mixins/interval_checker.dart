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
/// on 17/05/22
mixin InternalChecker on Component {
  /// Map available to store times that can be used to control
  ///  the frequency of any action.
  Map<String, IntervalTick>? _timers;

  /// Returns true if for each time the defined millisecond interval passes.
  /// Like a `Timer.periodic`
  /// Used in flows involved in the [update]
  bool checkInterval(
    String key,
    int intervalInMilli,
    double dt, {
    bool firstCheckIsTrue = true,
  }) {
    _timers ??= {};
    if (_timers![key]?.interval != intervalInMilli) {
      _timers![key] = IntervalTick(intervalInMilli);
      return firstCheckIsTrue;
    } else {
      return _timers![key]?.update(dt) ?? false;
    }
  }

  void resetInterval(String key) {
    _timers?.remove(key);
  }

  void tickInterval(String key) {
    _timers?[key]?.tick();
  }

  void pauseEffectController(String key) {
    _timers?[key]?.pause();
  }

  void playInterval(String key) {
    _timers?[key]?.play();
  }

  bool invervalIsRunning(String key) {
    return _timers?[key]?.running ?? false;
  }

  @override
  void onRemove() {
    super.onRemove();
    _timers?.clear();
  }
}
