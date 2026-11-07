import 'dart:ui' show lerpDouble;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/pulse_value.dart';
import 'package:flutter/widgets.dart';

/// How a light interacts with the game scene.
enum LightingMode {
  /// Erases the ambient darkness inside the light shape and tints that area
  /// with [LightingConfig.color]. This is the classic "flashlight" behavior.
  cutout,

  /// Adds the light on top of the scene without erasing the ambient darkness.
  /// Useful for torches, magic, explosions and any emissive light, including
  /// on maps that have no ambient darkness at all.
  additive,
}

/// Class used to configure lighting
class LightingConfig {
  /// Radius of the lighting
  final double radius;

  /// Color of the lighting
  final Color color;

  /// Enable pulse effect in lighting
  final bool withPulse;

  /// Light follow component angle
  final bool useComponentAngle;

  /// Configure variation in pulse effect
  final double pulseVariation;

  /// Configure speed in pulse effect
  final double pulseSpeed;

  /// Configure curve in pulse effect
  final Curve pulseCurve;

  /// Configure blur in lighting. When `0`, the light has a crisp edge.
  final double blurBorder;

  /// Configure type of the lighting
  final LightingType type;

  /// Offset applied to the light, relative to the component center.
  final Vector2 align;

  /// How the light interacts with the scene.
  final LightingMode mode;

  late MaskFilter? _maskFilter;

  PulseValue? _pulseAnimation;

  LightingConfig({
    required this.radius,
    required this.color,
    this.withPulse = false,
    this.useComponentAngle = false,
    this.pulseCurve = Curves.decelerate,
    this.pulseVariation = 0.1,
    this.pulseSpeed = 0.1,
    double? blurBorder,
    this.type = LightingType.circle,
    Vector2? align,
    this.mode = LightingMode.cutout,
  })  : align = align?.clone() ?? Vector2.zero(),
        blurBorder = blurBorder ?? radius {
    _pulseAnimation = PulseValue(
      speed: pulseSpeed,
      curve: pulseCurve,
      pulseVariation: pulseVariation,
    );

    _maskFilter = this.blurBorder > 0
        ? MaskFilter.blur(
            BlurStyle.normal,
            _convertRadiusToSigma(this.blurBorder),
          )
        : null;
  }

  void update(double dt) {
    if (withPulse) {
      _pulseAnimation?.update(dt);
    }
  }

  double get valuePulse => _pulseAnimation?.value ?? 0.0;

  /// Blur applied to the light edge. `null` means a crisp edge.
  MaskFilter? get maskFilter => _maskFilter;

  static double _convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  /// Returns a copy with the given fields replaced.
  ///
  /// All fields are preserved, including [align] and [mode].
  LightingConfig copyWith({
    double? radius,
    Color? color,
    bool? withPulse,
    bool? useComponentAngle,
    double? pulseVariation,
    double? pulseSpeed,
    Curve? pulseCurve,
    double? blurBorder,
    LightingType? type,
    Vector2? align,
    LightingMode? mode,
  }) {
    return LightingConfig(
      radius: radius ?? this.radius,
      color: color ?? this.color,
      withPulse: withPulse ?? this.withPulse,
      useComponentAngle: useComponentAngle ?? this.useComponentAngle,
      pulseVariation: pulseVariation ?? this.pulseVariation,
      pulseSpeed: pulseSpeed ?? this.pulseSpeed,
      pulseCurve: pulseCurve ?? this.pulseCurve,
      blurBorder: blurBorder ?? this.blurBorder,
      type: type ?? this.type,
      align: align ?? this.align,
      mode: mode ?? this.mode,
    );
  }

  /// Interpolates between this config and [other].
  ///
  /// Used by `LightingApi.animateTo` to animate radius, color, blur and
  /// alignment. Discrete fields switch at the middle of the animation.
  LightingConfig lerpTo(LightingConfig other, double t) {
    final discrete = t < 0.5;
    return LightingConfig(
      radius: lerpDouble(radius, other.radius, t)!,
      color: Color.lerp(color, other.color, t)!,
      withPulse: discrete ? withPulse : other.withPulse,
      useComponentAngle: discrete ? useComponentAngle : other.useComponentAngle,
      pulseVariation: lerpDouble(pulseVariation, other.pulseVariation, t)!,
      pulseSpeed: lerpDouble(pulseSpeed, other.pulseSpeed, t)!,
      pulseCurve: discrete ? pulseCurve : other.pulseCurve,
      blurBorder: lerpDouble(blurBorder, other.blurBorder, t)!,
      type: discrete ? type : other.type,
      align: Vector2(
        lerpDouble(align.x, other.align.x, t)!,
        lerpDouble(align.y, other.align.y, t)!,
      ),
      mode: discrete ? mode : other.mode,
    );
  }
}
