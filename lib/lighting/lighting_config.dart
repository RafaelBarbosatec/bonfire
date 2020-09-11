import 'package:bonfire/util/pulse_value.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class LightingConfig {
  final double radius;
  final Color color;
  final bool withPulse;
  final double pulseVariation;
  final double pulseSpeed;
  final double blurBorder;
  final Curve pulseCurve;
  PulseValue _pulseAnimation;

  LightingConfig({
    @required this.radius,
    this.color,
    this.withPulse = false,
    this.pulseCurve = Curves.decelerate,
    this.pulseVariation = 0.1,
    this.pulseSpeed = 1,
    this.blurBorder = 20,
  }) {
    _pulseAnimation = PulseValue(speed: pulseSpeed, curve: pulseCurve);
  }

  void update(double t) {
    _pulseAnimation.update(t);
  }

  double get valuePulse => _pulseAnimation.value ?? 0.0;
}
