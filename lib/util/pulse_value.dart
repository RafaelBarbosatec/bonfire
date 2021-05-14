import 'package:flutter/widgets.dart';

class PulseValue {
  final double speed;
  final Curve curve;
  double value = 0;
  bool _animIsReverse = false;
  double _controlAnim = 0;
  PulseValue({this.speed = 1, this.curve = Curves.decelerate});

  void update(double dt) {
    if (_animIsReverse) {
      _controlAnim -= dt * speed;
    } else {
      _controlAnim += dt * speed;
    }

    if (_controlAnim >= 1) {
      _controlAnim = 1;
      _animIsReverse = true;
    }
    if (_controlAnim <= 0) {
      _controlAnim = 0;
      _animIsReverse = false;
    }
    value = Curves.decelerate.transform(_controlAnim);
  }
}
