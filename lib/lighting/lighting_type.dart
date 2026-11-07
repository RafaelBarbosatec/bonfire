import 'package:flame/components.dart' show Vector2;

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
/// on 28/01/22
class LightingType {
  const LightingType();
  static const LightingType circle = CircleLightingType();
  static ArcLightingType arc({
    required double endRadAngle,
    double startRadAngle = 0,
    bool isCenter = false,
  }) =>
      ArcLightingType(
        endRadAngle: endRadAngle,
        startRadAngle: startRadAngle,
        isCenter: isCenter,
      );

  /// A rectangle centered on the light position, rotated by the light angle.
  ///
  /// [size] is the full width and height. The light `radius` sets its reach,
  /// so a rectangle with `size` larger than `radius` is scaled down to fit the
  /// configured radius (and it pulses/flickers with it).
  static RectLightingType rect(Vector2 size) => RectLightingType(size);

  /// An arbitrary polygon centered on the light position, rotated by the light
  /// angle.
  ///
  /// [points] are relative to the light center. The light `radius` is used as
  /// the reference distance for pulse, flicker and falloff.
  static PolygonLightingType polygon(List<Vector2> points) =>
      PolygonLightingType(points);
}

class CircleLightingType extends LightingType {
  const CircleLightingType();
}

class ArcLightingType extends LightingType {
  final double endRadAngle;
  final double startRadAngle;
  final bool isCenter;
  const ArcLightingType({
    required this.endRadAngle,
    this.startRadAngle = 0,
    this.isCenter = false,
  });
}

/// A rectangular light centered on the component.
class RectLightingType extends LightingType {
  /// Full width and height of the rectangle.
  final Vector2 size;

  const RectLightingType(this.size);
}

/// A light shaped as an arbitrary polygon.
class PolygonLightingType extends LightingType {
  /// Vertices relative to the light center.
  final List<Vector2> points;

  PolygonLightingType(List<Vector2> points)
      : points = List<Vector2>.unmodifiable(
          points.map((point) => point.clone()).toList(growable: false),
        );
}
