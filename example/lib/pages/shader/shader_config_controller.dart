// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class ShaderConfig {
  final double distortionStrength;
  final Color toneColor;
  final Color lightColor;
  final double speed;
  final double opacity;
  final Vector2 lightRange;

  ShaderConfig({
    this.distortionStrength = 0.05,
    this.toneColor = const Color(0xFF5ca4ec),
    this.lightColor = const Color(0xFFffffff),
    this.speed = 0.04,
    this.opacity = 0.7,
    Vector2? lightRange,
  }) : lightRange = lightRange ?? Vector2(0.4, 0.5);

  ShaderConfig copyWith({
    double? distortionStrength,
    Color? toneColor,
    Color? lightColor,
    double? speed,
    double? opacity,
    Vector2? lightRange,
  }) {
    return ShaderConfig(
      distortionStrength: distortionStrength ?? this.distortionStrength,
      toneColor: toneColor ?? this.toneColor,
      lightColor: lightColor ?? this.lightColor,
      speed: speed ?? this.speed,
      opacity: opacity ?? this.opacity,
      lightRange: lightRange ?? this.lightRange,
    );
  }
}

class ShaderConfigController extends ChangeNotifier {
  ShaderConfig _config = ShaderConfig();
  ShaderConfig get config => _config;

  void update(ShaderConfig config) {
    _config = config;
    notifyListeners();
  }
}
