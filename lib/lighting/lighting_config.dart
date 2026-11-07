import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/pulse_value.dart';
import 'package:flutter/widgets.dart';

/// How a light interacts with the game scene.
enum LightingMode {
  /// Erases the ambient darkness inside the light shape and tints that area
  /// with [LightingConfig.color]. This is the classic "flashlight" behavior.
  cutout,

  /// Adds light to the scene without erasing the ambient darkness.
  ///
  /// Additive lights are composited **below** the ambient color, so the night
  /// tint darkens them instead of having the light painted over the darkness.
  /// On maps without ambient darkness they simply glow over the scene.
  /// Useful for torches, magic, explosions and any emissive light.
  additive,
}

/// How the light fades from the center to its edge.
enum LightFalloff {
  /// Soft edge produced by `MaskFilter.blur` (the historical behavior).
  /// It still uses [LightingConfig.blurBorder].
  blur,

  /// Alpha decreases linearly from [LightingConfig.innerRadius] to the edge.
  linear,

  /// Alpha decreases with a smoothstep curve from
  /// [LightingConfig.innerRadius] to the edge.
  smooth,
}

/// Deterministic, candle-like flicker applied to a light.
///
/// [frequency] is roughly the number of oscillations per second, [amplitude] is
/// the relative variation (0.12 = ±12% on radius and intensity) and [seed]
/// produces different flicker patterns.
class LightFlicker {
  final double frequency;
  final double amplitude;
  final int seed;

  const LightFlicker({
    this.frequency = 8,
    this.amplitude = 0.12,
    this.seed = 0,
  }) : assert(amplitude >= 0 && amplitude <= 1);

  /// Returns a value in `[-1, 1]` for the given [time] in seconds.
  double sample(double time) {
    final t = time * frequency * math.pi * 2;
    final a = math.sin(t + seed * 0.7);
    final b = math.sin(t * 1.73 + seed * 1.3 + 1.7);
    final c = math.sin(t * 2.61 + seed * 0.3 + 3.1);
    return (a * 0.5 + b * 0.3 + c * 0.2).clamp(-1.0, 1.0);
  }
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
  ///
  /// Only used when [falloff] is [LightFalloff.blur].
  final double blurBorder;

  /// Configure type of the lighting
  final LightingType type;

  /// Offset applied to the light, relative to the component center.
  final Vector2 align;

  /// How the light interacts with the scene.
  final LightingMode mode;

  /// How the light fades to its edge.
  final LightFalloff falloff;

  /// Fraction of [radius] (0..1) where a gradient falloff still has full
  /// intensity. Only used by [LightFalloff.linear] and [LightFalloff.smooth].
  final double innerRadius;

  /// Light intensity in the `0..1` range. Multiplies the alpha of [color].
  final double intensity;

  /// Blend mode used by [LightingMode.additive] lights.
  final BlendMode additiveBlendMode;

  /// Optional candle-like flicker.
  final LightFlicker? flicker;

  late MaskFilter? _maskFilter;

  PulseValue? _pulseAnimation;

  double _flickerTime = 0;

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
    this.falloff = LightFalloff.blur,
    this.innerRadius = 0.35,
    this.intensity = 1,
    this.additiveBlendMode = BlendMode.plus,
    this.flicker,
  })  : assert(intensity >= 0 && intensity <= 1),
        assert(innerRadius >= 0 && innerRadius <= 1),
        align = align?.clone() ?? Vector2.zero(),
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
    if (flicker != null) {
      _flickerTime += dt;
    }
  }

  double get valuePulse => _pulseAnimation?.value ?? 0.0;

  /// Current flicker variation in `[-amplitude, amplitude]`. `0` when there is
  /// no [flicker].
  double get valueFlicker =>
      (flicker?.sample(_flickerTime) ?? 0) * (flicker?.amplitude ?? 0);

  /// [color] with [intensity] applied to its alpha.
  Color get effectiveColor => color.withValues(
        alpha: (color.a * intensity).clamp(0.0, 1.0),
      );

  /// Radius after the pulse and flicker are applied.
  double get radiusWithEffects {
    var value = radius * (1 - valuePulse);
    if (flicker != null) {
      value *= 1 + valueFlicker;
    }
    return math.max(0, value);
  }

  /// Blur applied to the light edge. `null` means a crisp edge.
  MaskFilter? get maskFilter => _maskFilter;

  static double _convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  /// Returns a copy with the given fields replaced.
  ///
  /// All fields are preserved, including [align], [mode] and [falloff].
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
    LightFalloff? falloff,
    double? innerRadius,
    double? intensity,
    BlendMode? additiveBlendMode,
    LightFlicker? flicker,
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
      falloff: falloff ?? this.falloff,
      innerRadius: innerRadius ?? this.innerRadius,
      intensity: intensity ?? this.intensity,
      additiveBlendMode: additiveBlendMode ?? this.additiveBlendMode,
      flicker: flicker ?? this.flicker,
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
      falloff: discrete ? falloff : other.falloff,
      innerRadius: lerpDouble(innerRadius, other.innerRadius, t)!,
      intensity: lerpDouble(intensity, other.intensity, t)!,
      additiveBlendMode: discrete ? additiveBlendMode : other.additiveBlendMode,
      flicker: discrete ? flicker : other.flicker,
    );
  }
}
