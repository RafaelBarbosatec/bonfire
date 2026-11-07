/// Quality used when a light casts shadows.
///
/// Shadows are computed by casting rays from the light center against the
/// registered [LightingOccluder]s and building a visibility polygon. More rays
/// produce more accurate silhouettes around occluder corners, at a higher CPU
/// cost. This only affects lights with `LightingConfig.castShadows = true`.
enum LightingQuality {
  /// 24 rays per light. Good for small lights or low end devices.
  low(24),

  /// 64 rays per light. The default balance between quality and cost.
  medium(64),

  /// 160 rays per light. Smooth silhouettes, recommended for a few large
  /// lights only.
  high(160);

  /// Number of rays cast around each light.
  final int shadowRays;

  const LightingQuality(this.shadowRays);
}
