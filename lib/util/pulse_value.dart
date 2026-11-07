import 'package:flutter/widgets.dart';

/// Animates a value between `0` and [pulseVariation] using [curve].
///
/// The animation is a ping-pong: it goes from `0` to [pulseVariation] and
/// back, forever. [speed] keeps the original timing: a full sweep from `0` to
/// [pulseVariation] takes `pulseVariation / speed` seconds.
class PulseValue {
  final double speed;
  final Curve curve;
  final double pulseVariation;
  bool _animIsReverse = false;

  /// Normalized animation progress, always between `0` and `1`.
  double phase = 0;

  /// Current animated value, always between `0` and [pulseVariation].
  double value = 0;

  PulseValue({
    this.speed = 1,
    this.curve = Curves.decelerate,
    this.pulseVariation = 0.1,
  });

  void update(double dt) {
    if (pulseVariation <= 0) {
      phase = 0;
      value = 0;
      return;
    }

    // Normalize the step so `speed` keeps the same meaning it had when the
    // internal controller was expressed in `pulseVariation` units.
    final step = (dt * speed) / pulseVariation;

    phase += _animIsReverse ? -step : step;

    if (phase >= 1) {
      phase = 1;
      _animIsReverse = true;
    } else if (phase <= 0) {
      phase = 0;
      _animIsReverse = false;
    }

    value = curve.transform(phase) * pulseVariation;
  }
}
