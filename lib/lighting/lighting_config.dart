import 'package:bonfire/util/pulse_value.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

/// Class used to configure lighting
class LightingConfig {
  /// Radius of the lighting
  final double radius;

  /// Color of the lighting
  final Color color;

  /// Enable pulse effect in lighting
  final bool withPulse;

  /// Configure variation in pulse effect
  final double pulseVariation;

  /// Configure speed in pulse effect
  final double pulseSpeed;

  /// Configure curve in pulse effect
  final Curve pulseCurve;

  /// Configure blur in lighting
  final double blurBorder;

  PulseValue? _pulseAnimation;

  LightingConfig({
    required this.radius,
    required this.color,
    this.withPulse = false,
    this.pulseCurve = Curves.decelerate,
    this.pulseVariation = 0.1,
    this.pulseSpeed = 1,
    this.blurBorder = 20,
  }) {
    _pulseAnimation = PulseValue(speed: pulseSpeed, curve: pulseCurve);
  }

  void update(double t) {
    _pulseAnimation?.update(t);
  }

  double get valuePulse => _pulseAnimation?.value ?? 0.0;
}
