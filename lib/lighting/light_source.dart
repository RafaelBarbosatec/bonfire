import 'package:bonfire/bonfire.dart';

/// A light that does not need to be attached to a component.
///
/// Add it through [LightingInterface.addLight] and remove it with
/// [LightingInterface.removeLight]:
///
/// ```dart
/// final flash = gameRef.lighting.addLight(
///   LightSource(
///     position: player.absoluteCenter.clone(),
///     config: LightingConfig(
///       radius: 160,
///       color: Colors.white.withValues(alpha: 0.9),
///       mode: LightingMode.additive,
///       falloff: LightFalloff.smooth,
///     ),
///   ),
/// );
///
/// gameRef.lighting.removeLight(flash);
/// ```
///
/// Useful for short-lived effects (explosions, muzzle flashes), ambient details
/// and lights that do not have a component of their own.
class LightSource {
  /// World position of the light center.
  Vector2 position;

  /// Configuration of the light.
  LightingConfig config;

  /// Whether this light is rendered.
  bool enabled;

  /// Rotation angle in radians. Used by [ArcLightingType].
  double angle;

  LightSource({
    required this.position,
    required this.config,
    this.enabled = true,
    this.angle = 0,
  });
}
