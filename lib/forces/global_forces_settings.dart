import 'package:bonfire/bonfire.dart';

class GlobalForcesSettings {
  final Vector2? gravity;
  final Vector2? wind;
  final Vector2? friction;
  final double? dragCoefficient;

  GlobalForcesSettings({
    this.gravity,
    this.wind,
    this.friction,
    this.dragCoefficient = 0.01,
  });
}
