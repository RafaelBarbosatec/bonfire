import 'package:bonfire/util/interval_tick.dart';

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
mixin InternalChecker {
  /// Map available to store times that can be used to control the frequency of any action.
  Map<String, IntervalTick>? _timers;

  /// Returns true if for each time the defined millisecond interval passes.
  /// Like a `Timer.periodic`
  /// Used in flows involved in the [update]
  bool checkInterval(String key, int intervalInMilli, double dt) {
    if (_timers == null) {
      _timers = Map();
    }
    if (this._timers![key]?.interval != intervalInMilli) {
      this._timers![key] = IntervalTick(intervalInMilli);
      return true;
    } else {
      return this._timers![key]?.update(dt) ?? false;
    }
  }
}
