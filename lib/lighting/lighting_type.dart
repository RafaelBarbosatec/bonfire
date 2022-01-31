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
