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
}
