import 'package:bonfire/lighting/lighting_component.dart';
import 'package:flutter/widgets.dart' show Color, Curve, Curves;

/// Ready-to-use ambient darkness colors.
///
/// ```dart
/// // Fade the scene into a night.
/// LightingPreset.night.apply(gameRef.lighting);
///
/// // Back to a fully lit map.
/// LightingPreset.day.apply(gameRef.lighting);
/// ```
///
/// The preset only changes the **ambient** color. Lights keep their own
/// configuration, so the same torch looks different during the day and at
/// night without touching the light itself.
enum LightingPreset {
  /// No ambient darkness. Cutout lights are not rendered (there is nothing to
  /// cut), but additive lights still glow.
  day(Color(0x00000000)),

  /// Warm, low opacity tint for sunsets and interiors lit by fire.
  dusk(Color(0x66FF7043)),

  /// Deep blue night.
  night(Color(0xE6020617)),

  /// Darker, slightly purple ambience for caves and dungeons.
  dungeon(Color(0xF20B0A12));

  /// Ambient color applied by this preset.
  final Color ambient;

  const LightingPreset(this.ambient);

  /// Whether this preset has no ambient darkness at all.
  bool get isDay => ambient.a == 0;

  /// Applies this preset to [lighting], fading the ambient color smoothly.
  ///
  /// [LightingPreset.day] fades the ambient darkness out; the other presets
  /// fade it in.
  void apply(
    LightingInterface lighting, {
    Duration duration = const Duration(milliseconds: 900),
    Curve curve = Curves.decelerate,
  }) {
    if (isDay) {
      lighting.fadeOut(duration: duration, curve: curve);
    } else {
      lighting.fadeIn(ambient, duration: duration, curve: curve);
    }
  }
}
