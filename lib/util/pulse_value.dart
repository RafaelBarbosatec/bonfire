import 'package:flutter/widgets.dart';

class PulseValue {
  final double speed;
  final Curve curve;
  final double pulseVariation;
  double value = 0;
  bool _animIsReverse = false;
  double _controlAnim = 0;
  PulseValue({
    this.speed = 1,
    this.curve = Curves.decelerate,
    this.pulseVariation = 0.1,
  });

  void update(double dt) {
    if (_animIsReverse) {
      _controlAnim -= dt * speed;
    } else {
      _controlAnim += dt * speed;
    }

    if (_controlAnim >= pulseVariation) {
      _controlAnim = pulseVariation;
      _animIsReverse = true;
    }
    if (_controlAnim <= 0) {
      _controlAnim = 0;
      _animIsReverse = false;
    }
    value = Curves.decelerate.transform(_controlAnim);
  }
}
